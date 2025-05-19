# Amazon CloudWatch

## Overview
Amazon CloudWatch provides monitoring and observability for AWS resources and applications. It collects logs, metrics, and events for real-time visibility.

## Real-life Use Cases
- **Cloud Architect:** Design dashboards for multi-account monitoring.
- **DevOps Engineer:** Set up alarms for auto-scaling and incident response.

## Terraform Example
```hcl
resource "aws_cloudwatch_log_group" "app_logs" {
  name = "/aws/app/logs"
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors high CPU usage"
  actions_enabled     = true
}
```

## AWS CLI Example
```sh
aws cloudwatch put-metric-alarm --alarm-name high-cpu --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 120 --threshold 80 --comparison-operator GreaterThanThreshold --evaluation-periods 2 --alarm-actions arn:aws:sns:us-east-1:123456789012:NotifyMe
```

## Best Practices
- Centralize logs using log groups.
- Use metric filters for custom metrics.
- Set actionable alarms.

## Common Pitfalls
- Not setting retention policies for logs.
- Too many alarms causing alert fatigue.

> **Joke:** Why did CloudWatch break up with EC2? Too many metrics, not enough commitment!
