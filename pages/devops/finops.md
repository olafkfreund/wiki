# FinOps Practices (2024+)

```ascii
Cost Optimization Lifecycle:
Plan → Monitor → Optimize
  ↑               ↓
  └───← Report ←──┘
```

### Cloud Cost Management

#### Resource Optimization

* Right-sizing
* Reserved Instances
* Spot Instances
* Auto-scaling

#### Cost Allocation

* Tagging Strategy
* Chargeback Models
* Showback Reports
* Budget Alerts

### Multi-Cloud FinOps

#### AWS Cost Controls

* Savings Plans
* AWS Cost Explorer
* AWS Budgets
* AWS Cost Anomaly Detection

#### Azure Cost Management

* Azure Reserved VM Instances
* Azure Hybrid Benefits
* Azure Cost Analysis
* Azure Budgets

#### GCP Cost Optimization

* Committed Use Discounts
* Preemptible VMs
* GCP Cost Explorer
* GCP Recommendations

### Implementation Examples

#### Terraform Cost Estimation

```hcl
terraform {
  required_providers {
    infracost = {
      source = "infracost/infracost"
    }
  }
}

provider "infracost" {}

resource "aws_instance" "web" {
  instance_type = "t3.micro"
  # Cost-effective instance selection
}

# Enable detailed monitoring only where needed
resource "aws_cloudwatch_metric_alarm" "cpu" {
  count = var.environment == "prod" ? 1 : 0
}
```

### Cost Optimization Practices

#### Development Environments

* Automated Shutdown
* Resource Limits
* Sandbox Environments
* Dev/Test Discounts

#### Production Optimization

* Performance/Cost Balance
* Capacity Planning
* Waste Reduction
* Architecture Optimization

#### Monitoring and Reporting

* Cost Dashboards
* Usage Analytics
* Trend Analysis
* Budget Tracking
