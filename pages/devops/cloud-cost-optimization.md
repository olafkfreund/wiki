# Cloud Cost Optimization (2024+)

## Multi-Cloud Cost Management

### Terraform Cost Estimation
```hcl
provider "infracost" {}

resource "aws_instance" "web_servers" {
  count         = var.environment == "prod" ? 3 : 1
  instance_type = var.environment == "prod" ? "t3.medium" : "t3.micro"
  
  tags = {
    Environment = var.environment
    CostCenter  = "web-${var.environment}"
  }
}
```

## FinOps Integration

### Cost Reporting Pipeline
```yaml
name: Cost Analysis
on:
  schedule:
    - cron: '0 1 * * *'
jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Infracost
        uses: infracost/infracost-action@v3
        with:
          api-key: ${{ secrets.INFRACOST_API_KEY }}
          terraform-dir: infrastructure/
      - name: Post Cost Report
        run: |
          curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
            -H 'Content-Type: application/json' \
            --data @infracost-report.json
```

## Cost Controls

### AWS Budget Alert
```yaml
resource "aws_budgets_budget" "cost_alert" {
  name         = "monthly-budget"
  budget_type  = "COST"
  limit_amount = "1000"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator = "GREATER_THAN"
    threshold          = 80
    threshold_type     = "PERCENTAGE"
    notification_type  = "ACTUAL"
  }
}
```

## Best Practices

1. **Resource Optimization**
   - Right-sizing
   - Auto-scaling
   - Reserved instances
   - Spot instances

2. **Cost Allocation**
   - Tagging strategy
   - Budget alerts
   - Cost anomaly detection
   - Chargeback implementation

3. **FinOps Culture**
   - Team accountability
   - Cost awareness
   - Optimization KPIs
   - Regular reviews

4. **Automation**
   - Cost estimation
   - Resource scheduling
   - Cleanup procedures
   - Report generation