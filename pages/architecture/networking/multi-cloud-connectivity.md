# Multi-Cloud Networking (2024+)

## Network Architecture

### AWS Transit Gateway Setup
```hcl
resource "aws_ec2_transit_gateway" "main" {
  description = "Multi-cloud transit gateway"
  
  tags = {
    Name = "multi-cloud-tgw"
    Environment = "production"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id            = var.vpc_id
  
  tags = {
    Name = "multi-cloud-attachment"
  }
}
```

## Azure Virtual WAN Integration

### Hub Configuration
```hcl
resource "azurerm_virtual_wan" "main" {
  name                = "multi-cloud-vwan"
  resource_group_name = azurerm_resource_group.networking.name
  location            = var.location
  
  type = "Standard"
}

resource "azurerm_virtual_hub" "main" {
  name                = "multi-cloud-hub"
  resource_group_name = azurerm_resource_group.networking.name
  location            = var.location
  virtual_wan_id      = azurerm_virtual_wan.main.id
  address_prefix      = "10.0.0.0/23"
}
```

## GCP Network Connectivity Center

### Cloud Router Setup
```hcl
resource "google_compute_router" "main" {
  name    = "multi-cloud-router"
  network = google_compute_network.main.name
  region  = var.region
  
  bgp {
    asn = 65000
  }
}

resource "google_network_connectivity_hub" "main" {
  name = "multi-cloud-hub"
  
  labels = {
    type = "multi-cloud"
  }
}
```

## Security Implementation

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: multi-cloud-policy
spec:
  podSelector:
    matchLabels:
      app: secure-service
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          cloud: aws
    - namespaceSelector:
        matchLabels:
          cloud: azure
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/8
```

## Best Practices

1. **Connectivity Design**
   - Hub-spoke topology
   - Transit routing
   - Bandwidth planning
   - Failover design

2. **Security Controls**
   - Microsegmentation
   - Traffic inspection
   - Encryption in transit
   - Access controls

3. **Monitoring**
   - Performance metrics
   - Latency tracking
   - Cost analysis
   - Security events

4. **Operations**
   - Change management
   - Disaster recovery
   - Capacity planning
   - Troubleshooting