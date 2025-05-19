---
description: Deploying and managing Google Cloud CDN for content delivery
---

# Cloud CDN

Google Cloud CDN (Content Delivery Network) uses Google's globally distributed edge points of presence to cache HTTP(S) content close to your users. By caching content at the edge, Cloud CDN accelerates content delivery, reduces serving costs, and helps alleviate the load on your backend servers.

## Key Features

- **Global Edge Network**: Leverage Google's global edge network spanning 100+ locations
- **Origin Support**: Works with Cloud Storage buckets, Compute Engine instances, GKE services, or external origins
- **HTTP/2 and QUIC**: Support for modern web protocols
- **SSL**: Automatic SSL certificate management
- **Cache Control**: Fine-grained cache control through standard HTTP headers
- **Cache Invalidation**: API for fast content invalidation
- **Signed URLs/Cookies**: Protected access to cached content
- **Metrics and Logging**: Real-time monitoring and detailed logging
- **Media Optimization**: Optimize delivery for video streaming and large files
- **Security Features**: Integration with Cloud Armor for WAF and DDoS protection

## Deploying Cloud CDN with Terraform

### Basic Setup with Cloud Storage Backend

```hcl
# Create a storage bucket to serve as the CDN origin
resource "google_storage_bucket" "cdn_bucket" {
  name          = "my-cdn-content-bucket"
  location      = "US"
  storage_class = "STANDARD"
  
  # Enable website serving
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  
  # Enforce uniform bucket-level access
  uniform_bucket_level_access = true
  
  # Make objects publicly readable
  force_destroy = true
}

# Upload sample content
resource "google_storage_bucket_object" "sample_content" {
  name        = "index.html"
  bucket      = google_storage_bucket.cdn_bucket.name
  content     = "<html><body>Hello from Cloud CDN!</body></html>"
  content_type = "text/html"
}

# Grant public read access to objects
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.cdn_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Create a compute backend service for the CDN
resource "google_compute_backend_bucket" "cdn_backend" {
  name        = "cdn-backend-bucket"
  description = "Backend bucket for serving content via CDN"
  bucket_name = google_storage_bucket.cdn_bucket.name
  
  # Enable CDN
  enable_cdn = true
  
  # Configure caching behavior
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600  # 1 hour
    default_ttl       = 3600  # 1 hour
    max_ttl           = 86400 # 24 hours
    negative_caching  = true
    
    # Cache static content types automatically
    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = false
    }
  }
}

# Create a URL map to route requests to the backend
resource "google_compute_url_map" "cdn_url_map" {
  name            = "cdn-url-map"
  description     = "URL map for CDN"
  default_service = google_compute_backend_bucket.cdn_backend.id
}

# Create an HTTP target proxy
resource "google_compute_target_http_proxy" "cdn_http_proxy" {
  name    = "cdn-http-proxy"
  url_map = google_compute_url_map.cdn_url_map.id
}

# Create a global forwarding rule (the entrypoint for the CDN)
resource "google_compute_global_forwarding_rule" "cdn_forwarding_rule" {
  name       = "cdn-forwarding-rule"
  target     = google_compute_target_http_proxy.cdn_http_proxy.id
  port_range = "80"
  ip_protocol = "TCP"
}

# Output the CDN URL
output "cdn_url" {
  value = "http://${google_compute_global_forwarding_rule.cdn_forwarding_rule.ip_address}"
}
```

### HTTPS Configuration with Custom Domain

```hcl
# Create a storage bucket as the CDN origin
resource "google_storage_bucket" "https_cdn_bucket" {
  name          = "my-secure-cdn-bucket"
  location      = "US"
  storage_class = "STANDARD"
  
  uniform_bucket_level_access = true
  force_destroy = true
}

# Reserve a static external IP address
resource "google_compute_global_address" "cdn_ip" {
  name = "cdn-static-ip"
}

# Create a managed SSL certificate
resource "google_compute_managed_ssl_certificate" "cdn_certificate" {
  name = "cdn-managed-certificate"

  managed {
    domains = ["cdn.example.com"]
  }
}

# Create a compute backend service for the CDN
resource "google_compute_backend_bucket" "https_cdn_backend" {
  name        = "https-cdn-backend-bucket"
  bucket_name = google_storage_bucket.https_cdn_bucket.name
  enable_cdn  = true
  
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600
    default_ttl       = 3600
    max_ttl           = 86400
    serve_while_stale = 86400  # Serve stale content for up to 24 hours while revalidating
    signed_url_cache_max_age_sec = 7200
  }
}

# Create a URL map
resource "google_compute_url_map" "https_cdn_url_map" {
  name            = "https-cdn-url-map"
  default_service = google_compute_backend_bucket.https_cdn_backend.id
}

# Create an HTTPS target proxy with the SSL certificate
resource "google_compute_target_https_proxy" "https_cdn_proxy" {
  name             = "https-cdn-proxy"
  url_map          = google_compute_url_map.https_cdn_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.cdn_certificate.id]
}

# Create a global forwarding rule (the entrypoint for the CDN)
resource "google_compute_global_forwarding_rule" "https_cdn_forwarding_rule" {
  name       = "https-cdn-forwarding-rule"
  target     = google_compute_target_https_proxy.https_cdn_proxy.id
  port_range = "443"
  ip_address = google_compute_global_address.cdn_ip.address
  ip_protocol = "TCP"
}

# Output the CDN domain and IP
output "cdn_ip" {
  value = google_compute_global_address.cdn_ip.address
}

output "cdn_url" {
  value = "https://cdn.example.com"
}

output "dns_record_value" {
  value = "Add an A record for cdn.example.com pointing to ${google_compute_global_address.cdn_ip.address}"
}
```

### Advanced Configuration with Load Balancer and Cloud Armor

```hcl
# Create a VPC network
resource "google_compute_network" "cdn_network" {
  name                    = "cdn-network"
  auto_create_subnetworks = false
}

# Create a subnet
resource "google_compute_subnetwork" "cdn_subnet" {
  name          = "cdn-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.cdn_network.id
}

# Create a firewall rule to allow HTTP/HTTPS traffic
resource "google_compute_firewall" "cdn_firewall" {
  name    = "cdn-firewall-allow-http-https"
  network = google_compute_network.cdn_network.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# Create an instance template for the origin servers
resource "google_compute_instance_template" "origin_template" {
  name_prefix  = "origin-template-"
  machine_type = "e2-medium"
  
  tags = ["web-server"]

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
    disk_size_gb = 20
  }

  network_interface {
    network    = google_compute_network.cdn_network.id
    subnetwork = google_compute_subnetwork.cdn_subnet.id
    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    cat <<EOF > /var/www/html/index.html
    <html><body>
      <h1>Hello from Google Cloud CDN!</h1>
      <p>Server: $(hostname)</p>
      <p>Time: $(date)</p>
    </body></html>
    EOF
  EOT

  lifecycle {
    create_before_destroy = true
  }
}

# Create an instance group manager
resource "google_compute_instance_group_manager" "origin_group" {
  name               = "origin-group-manager"
  base_instance_name = "origin"
  zone               = "us-central1-a"
  target_size        = 2
  
  version {
    instance_template = google_compute_instance_template.origin_template.id
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http_health_check.id
    initial_delay_sec = 300
  }
}

# Create a health check
resource "google_compute_health_check" "http_health_check" {
  name               = "http-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  
  http_health_check {
    port         = 80
    request_path = "/health-check"
  }
}

# Create a Cloud Armor security policy
resource "google_compute_security_policy" "cdn_security_policy" {
  name = "cdn-security-policy"
  
  # Block countries you don't do business with
  rule {
    action   = "deny(403)"
    priority = 1000
    match {
      expr {
        expression = "origin.region_code == 'ZZ'"  # Replace ZZ with actual country code
      }
    }
    description = "Block specific countries"
  }
  
  # Block known bad IPs
  rule {
    action   = "deny(403)"
    priority = 2000
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sql-injection')"
      }
    }
    description = "Block SQL injection attempts"
  }
  
  # Default rule - allow all other traffic
  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default rule"
  }
}

# Create a backend service
resource "google_compute_backend_service" "cdn_backend_service" {
  name                            = "cdn-backend-service"
  protocol                        = "HTTP"
  port_name                       = "http"
  timeout_sec                     = 10
  enable_cdn                      = true
  connection_draining_timeout_sec = 300
  health_checks                   = [google_compute_health_check.http_health_check.id]
  security_policy                 = google_compute_security_policy.cdn_security_policy.id
  
  backend {
    group = google_compute_instance_group_manager.origin_group.instance_group
  }
  
  cdn_policy {
    cache_mode                   = "USE_ORIGIN_HEADERS"
    default_ttl                  = 3600
    max_ttl                      = 86400
    client_ttl                   = 600
    negative_caching             = true
    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = true
    }
    signed_url_cache_max_age_sec = 7200
  }
  
  custom_response_headers = [
    "X-Cache-Status: {cdn_cache_status}",
    "X-Cache-ID: {cdn_cache_id}",
    "Strict-Transport-Security: max-age=31536000; includeSubDomains; preload"
  ]
}

# Create a URL map
resource "google_compute_url_map" "cdn_url_map" {
  name            = "cdn-url-map"
  default_service = google_compute_backend_service.cdn_backend_service.id
  
  # Path matcher for specific routes
  host_rule {
    hosts        = ["cdn.example.com"]
    path_matcher = "path-matcher"
  }
  
  path_matcher {
    name            = "path-matcher"
    default_service = google_compute_backend_service.cdn_backend_service.id
    
    path_rule {
      paths   = ["/images/*"]
      service = google_compute_backend_bucket.images_backend.id
    }
    
    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.api_backend_service.id
    }
  }
}

# Create a backend bucket for static images
resource "google_storage_bucket" "images_bucket" {
  name     = "cdn-images-bucket"
  location = "US"
}

resource "google_compute_backend_bucket" "images_backend" {
  name        = "images-backend"
  bucket_name = google_storage_bucket.images_bucket.name
  enable_cdn  = true
  
  cdn_policy {
    cache_mode = "CACHE_ALL_STATIC"
    default_ttl = 86400  # 24 hours
    max_ttl     = 604800 # 7 days
  }
}

# Create a backend service for API calls (no caching)
resource "google_compute_backend_service" "api_backend_service" {
  name        = "api-backend-service"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30
  enable_cdn  = false  # No caching for API calls
  
  backend {
    group = google_compute_instance_group_manager.origin_group.instance_group
  }
  
  health_checks = [google_compute_health_check.http_health_check.id]
}

# Create SSL certificate
resource "google_compute_managed_ssl_certificate" "cdn_certificate" {
  name = "cdn-managed-certificate"

  managed {
    domains = ["cdn.example.com"]
  }
}

# Create HTTPS target proxy
resource "google_compute_target_https_proxy" "cdn_https_proxy" {
  name             = "cdn-https-proxy"
  url_map          = google_compute_url_map.cdn_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.cdn_certificate.id]
}

# Create global forwarding rule for HTTPS
resource "google_compute_global_forwarding_rule" "cdn_https_forwarding_rule" {
  name       = "cdn-https-forwarding-rule"
  target     = google_compute_target_https_proxy.cdn_https_proxy.id
  port_range = "443"
  ip_protocol = "TCP"
}

# Create HTTP target proxy for redirect
resource "google_compute_target_http_proxy" "cdn_http_proxy" {
  name    = "cdn-http-proxy"
  url_map = google_compute_url_map.http_redirect.id
}

# Create HTTP to HTTPS redirect URL map
resource "google_compute_url_map" "http_redirect" {
  name = "http-redirect"
  
  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

# Create global forwarding rule for HTTP (redirects to HTTPS)
resource "google_compute_global_forwarding_rule" "cdn_http_forwarding_rule" {
  name       = "cdn-http-forwarding-rule"
  target     = google_compute_target_http_proxy.cdn_http_proxy.id
  port_range = "80"
  ip_protocol = "TCP"
}
```

## Managing Cloud CDN with gcloud CLI

### Setting up Cloud CDN with a Load Balancer

```bash
# Create a GCS bucket as origin
gsutil mb -l us-central1 gs://my-cdn-bucket

# Make bucket publicly readable
gsutil iam ch allUsers:objectViewer gs://my-cdn-bucket

# Upload content to the bucket
echo "<html><body>Hello from Cloud CDN</body></html>" > index.html
gsutil cp index.html gs://my-cdn-bucket/

# Create a backend bucket with Cloud CDN enabled
gcloud compute backend-buckets create my-cdn-backend \
  --gcs-bucket-name=my-cdn-bucket \
  --enable-cdn

# Create a URL map to route requests to the backend
gcloud compute url-maps create my-cdn-url-map \
  --default-backend-bucket=my-cdn-backend

# Create an HTTP target proxy
gcloud compute target-http-proxies create my-http-proxy \
  --url-map=my-cdn-url-map

# Create a global forwarding rule (frontend)
gcloud compute forwarding-rules create my-http-forwarding-rule \
  --global \
  --target-http-proxy=my-http-proxy \
  --ports=80
```

### Setting up Cloud CDN with Compute Engine Backends

```bash
# Create a health check
gcloud compute health-checks create http http-basic-check \
  --port=80 \
  --request-path=/health.html

# Create an instance template
gcloud compute instance-templates create web-template \
  --machine-type=e2-medium \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --tags=http-server \
  --metadata=startup-script='#! /bin/bash
    apt-get update
    apt-get install -y apache2
    cat > /var/www/html/index.html << EOF
    <html><body>
      <h1>Hello from Google Cloud CDN!</h1>
      <p>Time: $(date)</p>
    </body></html>
    cat > /var/www/html/health.html << EOF
    OK
    EOF'

# Create an instance group
gcloud compute instance-groups managed create web-group \
  --zone=us-central1-a \
  --size=2 \
  --template=web-template \
  --health-check=http-basic-check \
  --initial-delay=300

# Create a backend service with Cloud CDN enabled
gcloud compute backend-services create web-backend-service \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=http-basic-check \
  --enable-cdn \
  --global

# Add the instance group to the backend service
gcloud compute backend-services add-backend web-backend-service \
  --instance-group=web-group \
  --instance-group-zone=us-central1-a \
  --global

# Create a URL map
gcloud compute url-maps create web-url-map \
  --default-service=web-backend-service

# Create an HTTP target proxy
gcloud compute target-http-proxies create web-http-proxy \
  --url-map=web-url-map

# Create a forwarding rule
gcloud compute forwarding-rules create web-forwarding-rule \
  --global \
  --target-http-proxy=web-http-proxy \
  --ports=80
```

### Managing Cache Invalidation

```bash
# Invalidate a specific file
gcloud compute url-maps invalidate-cdn-cache my-cdn-url-map \
  --path="/images/logo.png"

# Invalidate a directory and all its contents
gcloud compute url-maps invalidate-cdn-cache my-cdn-url-map \
  --path="/css/*"

# Invalidate all content
gcloud compute url-maps invalidate-cdn-cache my-cdn-url-map \
  --path="/*"

# Invalidate with host
gcloud compute url-maps invalidate-cdn-cache my-cdn-url-map \
  --path="/js/app.js" \
  --host="cdn.example.com"
```

## Real-World Example: Multi-Region Static Website with Cloud CDN

This example demonstrates a complete setup for a multi-region, high-performance static website using Cloud Storage, Cloud CDN, and Cloud Load Balancing:

### Architecture Overview

1. Cloud Storage buckets in multiple regions for origin content
2. Cloud Load Balancer for global routing
3. Cloud CDN for edge caching
4. Cloud Armor for security
5. Custom domain with SSL

### Terraform Implementation

```hcl
provider "google" {
  project = var.project_id
  region  = "us-central1"
}

# Variables
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the website"
  type        = string
  default     = "example.com"
}

# Create regional buckets for redundancy
resource "google_storage_bucket" "primary_bucket" {
  name          = "${var.project_id}-website-us"
  location      = "US"
  storage_class = "STANDARD"
  
  uniform_bucket_level_access = true
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  
  cors {
    origin          = ["https://${var.domain_name}"]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["Content-Type", "Cache-Control"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket" "backup_bucket" {
  name          = "${var.project_id}-website-eu"
  location      = "EU"
  storage_class = "STANDARD"
  
  uniform_bucket_level_access = true
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  
  cors {
    origin          = ["https://${var.domain_name}"]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["Content-Type", "Cache-Control"]
    max_age_seconds = 3600
  }
}

# Create IAM policies for the buckets
resource "google_storage_bucket_iam_member" "primary_bucket_viewer" {
  bucket = google_storage_bucket.primary_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "backup_bucket_viewer" {
  bucket = google_storage_bucket.backup_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Create backend buckets for Cloud CDN
resource "google_compute_backend_bucket" "primary_backend" {
  name        = "primary-website-backend"
  description = "Primary website backend bucket"
  bucket_name = google_storage_bucket.primary_bucket.name
  enable_cdn  = true
  
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600
    default_ttl       = 3600
    max_ttl           = 86400
    negative_caching  = true
    serve_while_stale = 86400
    
    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = false
    }
  }
}

resource "google_compute_backend_bucket" "backup_backend" {
  name        = "backup-website-backend"
  description = "Backup website backend bucket"
  bucket_name = google_storage_bucket.backup_bucket.name
  enable_cdn  = true
  
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600
    default_ttl       = 3600
    max_ttl           = 86400
    negative_caching  = true
    serve_while_stale = 86400
  }
}

# Create health check for failover
resource "google_compute_health_check" "website_health_check" {
  name               = "website-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  
  http_health_check {
    port         = 80
    request_path = "/health.html"
  }
}

# Create a Cloud Armor security policy
resource "google_compute_security_policy" "website_security_policy" {
  name = "website-security-policy"
  
  # Rate limiting rule - 100 requests per minute per IP
  rule {
    action   = "throttle"
    priority = 1000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Rate limiting"
    
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
  
  # Block common web attacks
  rule {
    action   = "deny(403)"
    priority = 2000
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-stable')"
      }
    }
    description = "Block XSS attacks"
  }
  
  rule {
    action   = "deny(403)"
    priority = 2100
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sql-injection-stable')"
      }
    }
    description = "Block SQL injection attacks"
  }
  
  # Default rule
  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow rule"
  }
}

# Create URL map for failover routing
resource "google_compute_url_map" "website_url_map" {
  name            = "website-url-map"
  description     = "URL map for website with failover"
  default_service = google_compute_backend_bucket.primary_backend.id
  
  # Health check based failover
  path_matcher {
    name            = "failover"
    default_service = google_compute_backend_bucket.primary_backend.id
    
    route_rules {
      priority = 1
      service  = google_compute_backend_bucket.primary_backend.id
      
      # If primary is unhealthy, route to backup
      route_action {
        weighted_backend_services {
          backend_service = google_compute_backend_bucket.primary_backend.id
          weight          = 100
        }
        
        fault_injection_policy {
          abort {
            http_status = 502
            percentage  = 100
          }
        }
        
        request_mirror_policy {
          backend_service = google_compute_backend_bucket.backup_backend.id
        }
      }
    }
    
    route_rules {
      priority = 2
      service  = google_compute_backend_bucket.backup_backend.id
    }
  }
}

# Reserve a global IP address
resource "google_compute_global_address" "website_ip" {
  name = "website-global-ip"
}

# Create a managed SSL certificate
resource "google_compute_managed_ssl_certificate" "website_cert" {
  name = "website-ssl-cert"
  
  managed {
    domains = [var.domain_name, "www.${var.domain_name}"]
  }
}

# Create a HTTPS target proxy
resource "google_compute_target_https_proxy" "website_https_proxy" {
  name             = "website-https-proxy"
  url_map          = google_compute_url_map.website_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.website_cert.id]
}

# Create an HTTP target proxy for redirects
resource "google_compute_target_http_proxy" "website_http_proxy" {
  name    = "website-http-proxy"
  url_map = google_compute_url_map.http_redirect.id
}

# Create a URL map for HTTP to HTTPS redirect
resource "google_compute_url_map" "http_redirect" {
  name = "http-redirect"
  
  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

# Create global forwarding rules
resource "google_compute_global_forwarding_rule" "website_https_rule" {
  name       = "website-https-forwarding-rule"
  target     = google_compute_target_https_proxy.website_https_proxy.id
  port_range = "443"
  ip_address = google_compute_global_address.website_ip.address
}

resource "google_compute_global_forwarding_rule" "website_http_rule" {
  name       = "website-http-forwarding-rule"
  target     = google_compute_target_http_proxy.website_http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.website_ip.address
}

# Create DNS records
resource "google_dns_managed_zone" "website_zone" {
  name     = "website-zone"
  dns_name = "${var.domain_name}."
}

resource "google_dns_record_set" "website_record" {
  name         = "${var.domain_name}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.website_zone.name
  rrdatas      = [google_compute_global_address.website_ip.address]
}

resource "google_dns_record_set" "www_record" {
  name         = "www.${var.domain_name}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.website_zone.name
  rrdatas      = [google_compute_global_address.website_ip.address]
}

# Output important information
output "website_ip" {
  value = google_compute_global_address.website_ip.address
}

output "website_url" {
  value = "https://${var.domain_name}"
}

output "bucket_urls" {
  value = {
    primary = google_storage_bucket.primary_bucket.url
    backup  = google_storage_bucket.backup_bucket.url
  }
}

output "cdn_update_command" {
  value = "To invalidate cache: gcloud compute url-maps invalidate-cdn-cache website-url-map --path='/*'"
}
```

### Shell Script for Content Deployment

```bash
#!/bin/bash
# deploy_website.sh - Deploy website content to multi-region setup

# Configuration
PROJECT_ID="my-project-id"
PRIMARY_BUCKET="gs://${PROJECT_ID}-website-us"
BACKUP_BUCKET="gs://${PROJECT_ID}-website-eu"
WEBSITE_DIR="./website"

# Check if gsutil is installed
if ! command -v gsutil &> /dev/null; then
    echo "gsutil could not be found. Please install the Google Cloud SDK."
    exit 1
fi

# Validate website directory exists
if [ ! -d "$WEBSITE_DIR" ]; then
    echo "Website directory $WEBSITE_DIR not found."
    exit 1
fi

# Sync website content to primary bucket
echo "Deploying to primary bucket..."
gsutil -m rsync -r -d "$WEBSITE_DIR" "$PRIMARY_BUCKET"

# Set correct content types for web assets
echo "Setting content types..."
gsutil -m setmeta -r \
  -h "Cache-Control:public, max-age=3600" \
  "${PRIMARY_BUCKET}/**/*.html"

gsutil -m setmeta -r \
  -h "Cache-Control:public, max-age=86400" \
  "${PRIMARY_BUCKET}/**/*.css" \
  "${PRIMARY_BUCKET}/**/*.js"

gsutil -m setmeta -r \
  -h "Cache-Control:public, max-age=604800" \
  "${PRIMARY_BUCKET}/**/*.jpg" \
  "${PRIMARY_BUCKET}/**/*.png" \
  "${PRIMARY_BUCKET}/**/*.gif" \
  "${PRIMARY_BUCKET}/**/*.ico" \
  "${PRIMARY_BUCKET}/**/*.webp"

# Create health check file
echo "OK" > /tmp/health.html
gsutil cp /tmp/health.html "${PRIMARY_BUCKET}/health.html"

# Sync to backup bucket for failover
echo "Syncing to backup bucket..."
gsutil -m rsync -r -d "$PRIMARY_BUCKET" "$BACKUP_BUCKET"

# Invalidate CDN cache
echo "Invalidating CDN cache..."
gcloud compute url-maps invalidate-cdn-cache website-url-map --path="/*"

echo "Deployment completed successfully!"
```

## Best Practices

1. **Content Optimization**
   - Use appropriate caching headers (Cache-Control, Expires)
   - Enable gzip/Brotli compression for text-based content
   - Optimize images and use modern formats (WebP)
   - Implement HTTP/2 for better performance

2. **Cache Control Strategy**
   - Set longer TTLs for static content (images, JS, CSS)
   - Use shorter TTLs for frequently changing content
   - Implement versioned URLs for cache-busting
   - Consider negative caching for 404/5xx errors

3. **Security**
   - Use HTTPS with modern TLS versions
   - Implement Cloud Armor security policies
   - Use signed URLs/cookies for private content
   - Apply proper CORS settings for web applications

4. **Performance Monitoring**
   - Monitor cache hit ratios
   - Track origin load and bandwidth savings
   - Set up alerts for latency or error rate increases
   - Use Cloud Monitoring dashboards for CDN metrics

5. **Operations**
   - Plan cache invalidation strategies
   - Implement CI/CD for content updates
   - Configure multi-region origins for redundancy
   - Use canary deployments for high-traffic sites

## Common Issues and Troubleshooting

### Cache Misses
- Verify the cache policy is correctly configured
- Check the Cache-Control headers from the origin
- Ensure query strings are handled correctly in cache key
- Monitor for cache sharding (many unique URLs)
- Check if client caching headers differ from server headers

### SSL/TLS Issues
- Verify SSL certificate is valid and not expired
- Check SSL certificate covers all domains being served
- Ensure OCSP stapling is enabled
- Verify TLS version compatibility with clients
- Check for mixed content warnings

### Performance Problems
- Monitor latency by region and edge location
- Check for origin server performance issues
- Verify content compression is working
- Analyze cache hit ratios
- Optimize critical rendering path

### Content Updates Not Appearing
- Check cache invalidation status
- Verify cache TTL settings
- Use versioned URLs for static assets
- Check for stale-while-revalidate issues
- Monitor origin server reachability

## Further Reading

- [Cloud CDN Documentation](https://cloud.google.com/cdn/docs)
- [Cloud CDN Best Practices](https://cloud.google.com/cdn/docs/best-practices)
- [Terraform Google Cloud CDN Resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_bucket)
- [Cache Invalidation API](https://cloud.google.com/cdn/docs/cache-invalidation-overview)
- [Setting Up Cloud CDN with Cloud Storage](https://cloud.google.com/cdn/docs/setting-up-cdn-with-bucket)