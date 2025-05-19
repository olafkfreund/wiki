# Amazon Route 53

## Overview
Amazon Route 53 is a scalable DNS and domain name management service. It provides domain registration, DNS routing, and health checking.

## Real-life Use Cases
- **Cloud Architect:** Design global, highly available DNS architectures.
- **DevOps Engineer:** Automate DNS record management for blue/green deployments.

## Terraform Example
```hcl
resource "aws_route53_zone" "main" {
  name = "example.com."
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www"
  type    = "A"
  ttl     = 300
  records = ["1.2.3.4"]
}
```

## AWS CLI Example
```sh
aws route53 create-hosted-zone --name example.com --caller-reference 12345
aws route53 change-resource-record-sets --hosted-zone-id ZONEID --change-batch file://changes.json
```

## Best Practices
- Use alias records for AWS resources.
- Enable DNS failover for high availability.

## Common Pitfalls
- Not updating TTLs during migrations.
- Misconfigured health checks.

> **Joke:** Why did Route 53 get promoted? It always knew how to resolve issues!
