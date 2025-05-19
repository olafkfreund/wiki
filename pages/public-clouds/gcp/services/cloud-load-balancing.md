---
description: Distributing traffic across resources with Google Cloud Load Balancing
---

# Google Cloud Load Balancing

Google Cloud Load Balancing is a fully distributed, software-defined managed service for distributing traffic across applications and regions. It offers a range of load balancing options to support different types of traffic, from global external HTTP(S) traffic to internal TCP/UDP traffic within a single region.

## Key Features

- **Autoscaling**: Handles increases in traffic without pre-warming
- **Global and Regional**: Distribute traffic globally or within specific regions
- **Integrated with Google Cloud**: Works with Cloud CDN, Cloud Armor, and Monitoring
- **Intelligent traffic distribution**: Based on capacity, proximity, and health
- **Layer 4 and Layer 7 support**: Protocol and application-level load balancing
- **Modern protocols**: Support for HTTP/2 and QUIC
- **Security features**: Integration with Cloud Armor for DDoS protection and WAF capabilities

## Load Balancing Types

### Global Load Balancers

| Type | Use Case | Protocol Support | Notes |
|------|----------|------------------|-------|
| **Global External Application Load Balancer** | Global HTTP(S), gRPC traffic | HTTP, HTTPS, HTTP/2, gRPC | Integrate with Cloud CDN and Cloud Armor |
| **Global External Proxy Network Load Balancer** | Global TCP traffic | TCP, SSL | TLS termination, preserves client source IP |
| **Global External Classic Application Load Balancer** (Legacy) | HTTP(S) traffic | HTTP, HTTPS | Predecessor to Global External Application Load Balancer |

### Regional Load Balancers

| Type | Use Case | Protocol Support | Notes |
|------|----------|------------------|-------|
| **Regional External Application Load Balancer** | Regional HTTP(S) traffic | HTTP, HTTPS, HTTP/2, gRPC | Lower latency within a region |
| **Regional Internal Application Load Balancer** | Internal HTTP(S) traffic | HTTP, HTTPS, HTTP/2, gRPC | Private traffic inside VPC |
| **Regional External Network Load Balancer** | Regional TCP/UDP traffic | TCP, UDP, ICMP | Preserves client source IP |
| **Regional Internal Network Load Balancer** | Internal TCP/UDP traffic | TCP, UDP | Internal RFC 1918 clients |
| **Cross-region Internal Network Load Balancer** | Internal traffic across regions | TCP, UDP | Multi-region internal services |

## Choosing the Right Load Balancer

- **HTTP(S) Traffic**:
  - **Global reach needed**: Global External Application Load Balancer
  - **Single region traffic**: Regional External Application Load Balancer
  - **Internal services**: Regional Internal Application Load Balancer

- **TCP/UDP Traffic**:
  - **Global TCP**: Global External Proxy Network Load Balancer
  - **Regional TCP/UDP with preserved client IPs**: Regional External Network Load Balancer
  - **Internal TCP/UDP**: Regional Internal Network Load Balancer
  - **Cross-region internal**: Cross-region Internal Network Load Balancer

## Deployments with Terraform

### Global External Application Load Balancer

This setup creates a globally distributed HTTP load balancer for a web application:

```hcl
# Google Cloud Provider Configuration
provider "google" {
  project = "my-project-id"
  region  = "us-central1"
}

# Reserve a global static external IP address
resource "google_compute_global_address" "default" {
  name = "global-lb-ip"
}

# Create a backend service with health check
resource "google_compute_health_check" "default" {
  name               = "http-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  http_health_check {
    port         = 80
    request_path = "/health"
  }
}

# Create instance group for backend VMs
resource "google_compute_instance_group" "webservers" {
  name        = "webserver-group"
  description = "Web server instance group"
  zone        = "us-central1-a"

  named_port {
    name = "http"
    port = 80
  }
  
  # Note: In a real deployment, you would reference existing instances
  # or use an instance group manager with an instance template
}

# Backend service to distribute traffic to instances
resource "google_compute_backend_service" "default" {
  name                  = "web-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  enable_cdn            = true
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.default.id]

  backend {
    group           = google_compute_instance_group.webservers.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

  # Optional: Configure Cloud CDN
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600
    default_ttl       = 3600
    max_ttl           = 86400
    serve_while_stale = 86400
  }
}

# URL map to route requests to the backend service
resource "google_compute_url_map" "default" {
  name            = "web-url-map"
  default_service = google_compute_backend_service.default.id

  # Optional: Add path-based routing rules
  host_rule {
    hosts        = ["example.com"]
    path_matcher = "main"
  }

  path_matcher {
    name            = "main"
    default_service = google_compute_backend_service.default.id
    
    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.default.id
    }
  }
}

# HTTP target proxy to route requests to URL map
resource "google_compute_target_http_proxy" "default" {
  name    = "web-proxy"
  url_map = google_compute_url_map.default.id
}

# Global forwarding rule to route traffic to the proxy
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "web-forwarding-rule"
  ip_address            = google_compute_global_address.default.address
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  load_balancing_scheme = "EXTERNAL"
}

# Optional: Set up HTTPS with managed SSL certificate
resource "google_compute_managed_ssl_certificate" "default" {
  name = "web-ssl-cert"
  managed {
    domains = ["example.com"]
  }
}

resource "google_compute_target_https_proxy" "default" {
  name             = "web-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "web-https-forwarding-rule"
  ip_address            = google_compute_global_address.default.address
  port_range            = "443"
  target                = google_compute_target_https_proxy.default.id
  load_balancing_scheme = "EXTERNAL"
}
```

### Regional Internal Application Load Balancer

This setup creates a regional internal HTTP load balancer for internal microservices:

```hcl
# Define a regional internal application load balancer
resource "google_compute_region_health_check" "default" {
  name               = "internal-http-health-check"
  region             = "us-central1"
  check_interval_sec = 5
  timeout_sec        = 5
  http_health_check {
    port         = 8080
    request_path = "/healthz"
  }
}

# Create a regional backend service
resource "google_compute_region_backend_service" "default" {
  name                  = "internal-backend-service"
  region                = "us-central1"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  load_balancing_scheme = "INTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.default.id]

  backend {
    group           = google_compute_region_instance_group_manager.default.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# Create a URL map for routing
resource "google_compute_region_url_map" "default" {
  name            = "internal-url-map"
  region          = "us-central1"
  default_service = google_compute_region_backend_service.default.id
}

# Create regional HTTP proxy
resource "google_compute_region_target_http_proxy" "default" {
  name    = "internal-http-proxy"
  region  = "us-central1"
  url_map = google_compute_region_url_map.default.id
}

# Create a forwarding rule to route traffic to the proxy
resource "google_compute_forwarding_rule" "default" {
  name                  = "internal-forwarding-rule"
  region                = "us-central1"
  ip_protocol           = "TCP"
  port_range            = "8080"
  load_balancing_scheme = "INTERNAL_MANAGED"
  target                = google_compute_region_target_http_proxy.default.id
  network               = "default"
  subnetwork            = "default"
}

# Create a managed instance group for the backends
resource "google_compute_region_instance_group_manager" "default" {
  name               = "internal-service-mig"
  region             = "us-central1"
  base_instance_name = "service"
  
  version {
    instance_template = google_compute_instance_template.default.id
  }
  
  auto_healing_policies {
    health_check      = google_compute_region_health_check.default.id
    initial_delay_sec = 300
  }
  
  target_size = 2
}

# Define the instance template for the backends
resource "google_compute_instance_template" "default" {
  name         = "internal-service-template"
  machine_type = "e2-medium"
  
  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }
  
  network_interface {
    network = "default"
    
    # No access_config means no external IP
  }
  
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    cat > /var/www/html/healthz <<EOF
    OK
    EOF
    cat > /etc/nginx/sites-available/default <<EOF
    server {
      listen 8080;
      location / {
        root /var/www/html;
      }
      location /healthz {
        root /var/www/html;
      }
    }
    EOF
    systemctl restart nginx
  EOT
  
  tags = ["allow-health-check"]
}

# Create a firewall rule to allow health checks
resource "google_compute_firewall" "default" {
  name    = "allow-health-check"
  network = "default"
  
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["allow-health-check"]
}
```

### Regional External Network Load Balancer

This setup creates a regional external TCP load balancer that preserves client IP addresses:

```hcl
# Create a health check for the backend service
resource "google_compute_region_health_check" "tcp_health_check" {
  name               = "tcp-health-check"
  region             = "us-central1"
  check_interval_sec = 5
  timeout_sec        = 5
  tcp_health_check {
    port = 80
  }
}

# Create a regional backend service
resource "google_compute_region_backend_service" "backend" {
  name                  = "tcp-backend-service"
  region                = "us-central1"
  protocol              = "TCP"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_region_health_check.tcp_health_check.id]
  
  backend {
    group          = google_compute_instance_group.backends.id
    balancing_mode = "CONNECTION"
  }
}

# Create an instance group for the backends
resource "google_compute_instance_group" "backends" {
  name      = "tcp-backend-group"
  zone      = "us-central1-a"
  instances = [google_compute_instance.backend.id]

  named_port {
    name = "http"
    port = 80
  }
}

# Create a backend VM
resource "google_compute_instance" "backend" {
  name         = "tcp-backend-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
  EOT
}

# Reserve an external IP address
resource "google_compute_address" "lb_ip" {
  name   = "tcp-lb-ip"
  region = "us-central1"
}

# Create a forwarding rule
resource "google_compute_forwarding_rule" "tcp_forwarding_rule" {
  name                  = "tcp-forwarding-rule"
  region                = "us-central1"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  ip_address            = google_compute_address.lb_ip.address
  backend_service       = google_compute_region_backend_service.backend.id
}

# Create firewall rule to allow traffic from Google Load Balancers
resource "google_compute_firewall" "allow_lb" {
  name    = "allow-lb-to-backends"
  network = "default"
  
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
```

## Implementation with gcloud CLI

### Global External Application Load Balancer

```bash
# Create a global static IP address
gcloud compute addresses create global-lb-ip \
    --global

# Create health check
gcloud compute health-checks create http http-basic-check \
    --port=80 \
    --check-interval=5s \
    --timeout=5s \
    --healthy-threshold=2 \
    --unhealthy-threshold=2 \
    --request-path="/health"

# Create a backend service
gcloud compute backend-services create web-backend-service \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=http-basic-check \
    --global

# Add your instance group to the backend service
gcloud compute backend-services add-backend web-backend-service \
    --instance-group=webserver-group \
    --instance-group-zone=us-central1-a \
    --global

# Create URL map
gcloud compute url-maps create web-map \
    --default-service=web-backend-service

# Create HTTP target proxy
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map=web-map

# Create forwarding rule
gcloud compute forwarding-rules create http-content-rule \
    --address=global-lb-ip \
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80
```

### Regional Internal Application Load Balancer

```bash
# Create health check
gcloud compute health-checks create http internal-http-health-check \
    --port=8080 \
    --request-path="/healthz" \
    --check-interval=5s \
    --timeout=5s \
    --region=us-central1

# Create backend service
gcloud compute backend-services create internal-backend-service \
    --region=us-central1 \
    --health-checks=internal-http-health-check \
    --health-checks-region=us-central1 \
    --protocol=HTTP \
    --load-balancing-scheme=INTERNAL_MANAGED

# Add instance group to backend service
gcloud compute backend-services add-backend internal-backend-service \
    --instance-group=internal-service-mig \
    --instance-group-region=us-central1 \
    --region=us-central1

# Create URL map
gcloud compute url-maps create internal-url-map \
    --region=us-central1 \
    --default-service=internal-backend-service

# Create HTTP proxy
gcloud compute target-http-proxies create internal-http-proxy \
    --region=us-central1 \
    --url-map=internal-url-map \
    --url-map-region=us-central1

# Create forwarding rule
gcloud compute forwarding-rules create internal-forwarding-rule \
    --region=us-central1 \
    --load-balancing-scheme=INTERNAL_MANAGED \
    --network=default \
    --subnet=default \
    --target-http-proxy=internal-http-proxy \
    --target-http-proxy-region=us-central1 \
    --ports=8080
```

## Advanced Configurations

### Custom Headers and URL Rewrites

For Application Load Balancers, you can configure custom headers and URL rewrites:

```hcl
resource "google_compute_url_map" "advanced_url_map" {
  name            = "advanced-url-map"
  default_service = google_compute_backend_service.default.id

  host_rule {
    hosts        = ["example.com"]
    path_matcher = "advanced"
  }

  path_matcher {
    name            = "advanced"
    default_service = google_compute_backend_service.default.id
    
    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.api.id

      route_action {
        url_rewrite {
          path_prefix_rewrite = "/v1/"
        }
      }
    }

    path_rule {
      paths   = ["/legacy/*"]
      service = google_compute_backend_service.legacy.id

      header_action {
        request_headers_to_add {
          header_name  = "X-Source"
          header_value = "legacy-gateway"
          replace      = true
        }
      }
    }
  }
}
```

### Weighted Traffic Distribution

For Global Application Load Balancers, you can implement weighted traffic distribution for A/B testing or canary deployments:

```hcl
resource "google_compute_url_map" "weighted_url_map" {
  name            = "weighted-url-map"
  default_service = google_compute_backend_service.prod.id

  host_rule {
    hosts        = ["example.com"]
    path_matcher = "weighted"
  }

  path_matcher {
    name            = "weighted"
    default_service = google_compute_backend_service.prod.id
    
    route_rules {
      priority = 1
      match_rules {
        prefix_match = "/features/"
      }
      route_action {
        weighted_backend_services {
          backend_service = google_compute_backend_service.prod.id
          weight          = 90
        }
        weighted_backend_services {
          backend_service = google_compute_backend_service.canary.id
          weight          = 10
        }
      }
    }
  }
}
```

### Session Affinity

Configure session affinity to route requests from the same client to the same backend:

```hcl
resource "google_compute_backend_service" "affinity_service" {
  name                  = "affinity-backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.default.id]
  
  backend {
    group           = google_compute_instance_group.webservers.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
  
  session_affinity = "GENERATED_COOKIE"
  
  # For cookie-based affinity
  consistent_hash {
    http_cookie {
      name = "session-cookie"
      ttl {
        seconds = 3600
      }
    }
  }
}
```

### SSL Policies for Enhanced Security

Create a custom SSL policy for HTTPS load balancers:

```hcl
# Create custom SSL policy
resource "google_compute_ssl_policy" "secure_policy" {
  name            = "secure-ssl-policy"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
  
  # Optional: specify allowed cipher suites
  custom_features = [
    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
  ]
}

# Apply SSL policy to HTTPS proxy
resource "google_compute_target_https_proxy" "default" {
  name             = "web-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
  ssl_policy       = google_compute_ssl_policy.secure_policy.id
}
```

### Cloud Armor Integration for WAF and DDoS Protection

Add Cloud Armor security policy to your load balancer:

```hcl
# Create Cloud Armor security policy
resource "google_compute_security_policy" "policy" {
  name = "my-security-policy"

  # Default rule (lowest priority, evaluated last)
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["0.0.0.0/0"]
      }
    }
    description = "Default rule, allow all traffic"
  }

  # Block traffic from specific countries
  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      expr {
        expression = "origin.region_code == 'CN'"
      }
    }
    description = "Block traffic from China"
  }

  # Block common SQL injection patterns
  rule {
    action   = "deny(403)"
    priority = "2000"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-stable')"
      }
    }
    description = "Block SQL injection attempts"
  }

  # Rate limit by IP
  rule {
    action   = "rate_based_ban"
    priority = "3000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["0.0.0.0/0"]
      }
    }
    description = "Rate limit all traffic"
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"
      rate_limit_threshold {
        count        = 100
        interval_sec = 60
      }
    }
  }
}

# Apply security policy to backend service
resource "google_compute_backend_service" "default" {
  name                  = "web-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  enable_cdn            = true
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.default.id]
  security_policy       = google_compute_security_policy.policy.id

  backend {
    group           = google_compute_instance_group.webservers.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}
```

## Load Balancing Patterns

### Multi-Regional Active-Active

Deploy a global load balancer with backend services in multiple regions for high availability:

```hcl
resource "google_compute_backend_service" "multi_region" {
  name                  = "multi-region-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.default.id]
  
  # US region backend
  backend {
    group           = google_compute_instance_group.us_webservers.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
  
  # Europe region backend
  backend {
    group           = google_compute_instance_group.eu_webservers.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
  
  # Asia region backend
  backend {
    group           = google_compute_instance_group.asia_webservers.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
  
  # Use latency-based routing
  locality_lb_policy = "LEAST_REQUEST"
}
```

### Internal Microservices Architecture

Create internal load balancers for microservices communication:

```hcl
# Service A - Internal Load Balancer
resource "google_compute_region_backend_service" "service_a" {
  name                  = "service-a-backend"
  region                = "us-central1"
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.service_a_health.id]
  
  backend {
    group = google_compute_region_instance_group_manager.service_a.instance_group
    balancing_mode = "UTILIZATION"
  }
}

# Service B - Internal Load Balancer
resource "google_compute_region_backend_service" "service_b" {
  name                  = "service-b-backend"
  region                = "us-central1"
  protocol              = "HTTP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  health_checks         = [google_compute_region_health_check.service_b_health.id]
  
  backend {
    group = google_compute_region_instance_group_manager.service_b.instance_group
    balancing_mode = "UTILIZATION"
  }
}

# API Gateway - External Load Balancer
resource "google_compute_backend_service" "api_gateway" {
  name                  = "api-gateway-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.gateway_health.id]
  
  backend {
    group = google_compute_instance_group_manager.api_gateway.instance_group
    balancing_mode = "UTILIZATION"
  }
}
```

### CDN Integration Pattern

Integrate Cloud CDN with Application Load Balancer for static content:

```hcl
resource "google_compute_backend_service" "cdn_backend" {
  name                  = "cdn-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  enable_cdn            = true
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.default.id]

  backend {
    group           = google_compute_instance_group.webservers.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

  cdn_policy {
    cache_mode        = "USE_ORIGIN_HEADERS"
    client_ttl        = 3600
    default_ttl       = 3600
    max_ttl           = 86400
    negative_caching  = true
    serve_while_stale = 86400
    
    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = true
    }
  }
}
```

## Monitoring and Logging

### CloudWatch Metrics for Load Balancers

```hcl
# Create a dashboard for load balancer monitoring
resource "google_monitoring_dashboard" "lb_dashboard" {
  dashboard_json = <<EOF
{
  "displayName": "Load Balancer Dashboard",
  "gridLayout": {
    "columns": "2",
    "widgets": [
      {
        "title": "Request Count",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"loadbalancing.googleapis.com/https/request_count\" resource.type=\"https_lb_rule\" resource.label.\"forwarding_rule_name\"=\"${google_compute_global_forwarding_rule.default.name}\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_RATE"
                  }
                }
              }
            }
          ]
        }
      },
      {
        "title": "Backend Latency",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "metric.type=\"loadbalancing.googleapis.com/https/backend_latencies\" resource.type=\"https_lb_rule\" resource.label.\"forwarding_rule_name\"=\"${google_compute_global_forwarding_rule.default.name}\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_PERCENTILE_95"
                  }
                }
              }
            }
          ]
        }
      }
    ]
  }
}
EOF
}
```

### Setting Up Alerting Policies

```hcl
# Create alert policy for 5xx errors
resource "google_monitoring_alert_policy" "lb_5xx_errors" {
  display_name = "High 5xx Error Rate Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "Error Rate > 5%"
    
    condition_threshold {
      filter          = "metric.type=\"loadbalancing.googleapis.com/https/request_count\" resource.type=\"https_lb_rule\" resource.label.\"forwarding_rule_name\"=\"${google_compute_global_forwarding_rule.default.name}\" metric.label.\"response_code_class\"=\"500\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.05
      
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.label.forwarding_rule_name"]
      }
      
      denominator_filter = "metric.type=\"loadbalancing.googleapis.com/https/request_count\" resource.type=\"https_lb_rule\" resource.label.\"forwarding_rule_name\"=\"${google_compute_global_forwarding_rule.default.name}\""
      
      denominator_aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.label.forwarding_rule_name"]
      }
    }
  }
  
  notification_channels = [
    google_monitoring_notification_channel.email.id
  ]
  
  documentation {
    content   = "High rate of 5xx errors detected on load balancer ${google_compute_global_forwarding_rule.default.name}"
    mime_type = "text/markdown"
  }
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "DevOps Team Email"
  type         = "email"
  
  labels = {
    email_address = "devops@example.com"
  }
}
```

## Best Practices

1. **Choose the right load balancer**: Match your load balancer type to your traffic patterns and requirements

2. **Implement health checks properly**: Design health checks that accurately reflect service health, not just connectivity

3. **Utilize Cloud CDN**: Enable Cloud CDN for static content to reduce backend load and improve user experience

4. **Implement security layers**: Use Cloud Armor for WAF capabilities and DDoS protection

5. **Configure appropriate session affinity**: Choose the correct affinity method based on your application requirements

6. **Set up proper monitoring**: Configure dashboards and alerts for key metrics like latency, errors, and traffic

7. **Design for high availability**: Use multiple regions for global services and multiple zones for regional services

8. **Optimize backend instance groups**: Use managed instance groups with autoscaling for dynamic workloads

9. **Define custom headers for backend routing**: Add custom headers to help backend services identify traffic source

10. **Implement graceful backend transitions**: Use weighted traffic distribution for canary releases

11. **Configure appropriate timeouts**: Adjust timeout settings based on backend service response characteristics

## Troubleshooting

### Common Issues and Solutions

1. **5xx Errors from Load Balancer**
   - Check backend service health
   - Verify backend instance capacity
   - Inspect backend service logs for errors
   - Confirm firewall rules allow health check traffic

2. **High Latency**
   - Check backend service resource utilization
   - Verify proper region selection for regional load balancers
   - Enable and optimize Cloud CDN for cacheable content
   - Use network performance tests to identify bottlenecks

3. **SSL/TLS Certificate Problems**
   - Verify certificate validity and domain names
   - Check SSL policy configuration
   - Ensure certificates are properly uploaded and linked
   - Look for certificate mismatch errors in logs

4. **Load Balancer Not Distributing Traffic Evenly**
   - Review balancing mode settings
   - Check instance group health and capacity
   - Verify session affinity settings
   - Inspect health check pass/fail rates

### Diagnostic Commands

```bash
# Check health check status for instances
gcloud compute backend-services get-health web-backend-service \
    --global

# View recent load balancer logs
gcloud logging read 'resource.type=http_load_balancer AND resource.labels.forwarding_rule_name=web-forwarding-rule' \
    --limit=10

# Get load balancer details
gcloud compute forwarding-rules describe web-forwarding-rule \
    --global

# List SSL certificates
gcloud compute ssl-certificates list

# Test backend connectivity from Cloud Shell
curl -v --resolve example.com:443:$(gcloud compute addresses describe global-lb-ip --global --format='value(address)') https://example.com/
```

## Further Reading

- [Google Cloud Load Balancing Documentation](https://cloud.google.com/load-balancing/docs)
- [Choosing a Load Balancer](https://cloud.google.com/load-balancing/docs/choosing-load-balancer)
- [Cloud Armor Security Policies](https://cloud.google.com/armor/docs)
- [Cloud CDN Overview](https://cloud.google.com/cdn/docs)
- [Best Practices for Cloud Load Balancing](https://cloud.google.com/architecture/best-practices-cloud-load-balancing)