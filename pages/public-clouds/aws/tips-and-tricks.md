# AWS DevOps Engineering Tips & Tricks

## 🔑 Authentication & Security

### Cross-Account Access Management
```bash
# Use AWS Organizations for multi-account management
aws organizations list-accounts

# Assume role across accounts
aws sts assume-role --role-arn arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME --role-session-name SESSION_NAME
```

### Security Automation
```bash
# Find resources without required tags
aws resourcegroupstaggingapi get-resources --tag-filters Key=Environment,Values=[]

# Audit security group changes
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=AuthorizeSecurityGroupIngress
```

## 🚀 Infrastructure Optimization

### Cost Management
```bash
# List unused EBS volumes
aws ec2 describe-volumes --filters Name=status,Values=available

# Find unattached Elastic IPs
aws ec2 describe-addresses --filters Name=network-interface-id,Values=
```

### Resource Tagging Strategy
- Use standardized tag keys: Environment, Project, Owner, CostCenter
- Implement automatic tagging in CloudFormation/Terraform
- Regular tag compliance audits

## 💾 Data Management

### S3 Best Practices
```bash
# Enable default encryption
aws s3api put-bucket-encryption \
    --bucket my-bucket \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Configure lifecycle rules
aws s3api put-bucket-lifecycle-configuration \
    --bucket my-bucket \
    --lifecycle-configuration file://lifecycle.json
```

## 🔍 Monitoring & Alerting

### CloudWatch Insights
```bash
# Create metric filters from logs
aws logs put-metric-filter \
    --log-group-name my-log-group \
    --filter-name errors \
    --filter-pattern "ERROR" \
    --metric-transformations \
        metricName=ErrorCount,metricNamespace=MyApp,metricValue=1
```

### X-Ray Tracing Tips
- Use sampling rules effectively
- Implement custom subsegments for detailed tracing
- Monitor trace completion rates

## 🛠 Infrastructure as Code

### CloudFormation Advanced Features
- Use custom resources for complex operations
- Implement drift detection
- Use stacksets for multi-region/account deployments

### Terraform Integration
```hcl
# Use AWS provider with assume role
provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
  }
}
```

## 🚦 Network & Traffic Management

### VPC Flow Logs Analysis
```bash
# Enable VPC flow logs with Athena integration
aws ec2 create-flow-logs \
    --resource-type VPC \
    --resource-ids vpc-xxxxxxxx \
    --traffic-type ALL \
    --log-destination-type s3 \
    --log-destination arn:aws:s3:::my-bucket/flow-logs/
```

## 🤖 Automation & Scripting

### AWS Systems Manager Automation
```bash
# Create maintenance window tasks
aws ssm create-maintenance-window \
    --name "Weekly-Maintenance" \
    --schedule "cron(0 4 ? * SUN *)" \
    --duration 2 \
    --cutoff 1
```

### Lambda Function Management
```bash
# Add provisioned concurrency
aws lambda put-provisioned-concurrency-config \
    --function-name my-function \
    --qualifier prod \
    --provisioned-concurrent-executions 10
```

## 🔒 Security Best Practices

### IAM Security
- Use AWS Organizations SCP (Service Control Policies)
- Implement least privilege access
- Regular credential rotation
- Enable MFA for all users

### Encryption
- Use KMS for key management
- Enable encryption at rest for all services
- Implement envelope encryption for sensitive data

## 💰 Cost Optimization Techniques

### Reserved Instance Management
```bash
# Get RI coverage
aws ce get-reservation-coverage \
    --time-period Start=$(date -d "30 days ago" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
    --group-by Type=INSTANCE_TYPE
```

### Spot Instance Usage
- Use spot fleet for flexible workloads
- Implement instance interruption handling
- Monitor spot price history

## 🔄 Disaster Recovery

### Backup Strategies
```bash
# Create cross-region backup
aws backup start-copy-job \
    --recovery-point-arn arn:aws:backup:region1:account:recovery-point:ID \
    --destination-region region2 \
    --iam-role-arn arn:aws:iam::account:role/service-role/backup-role
```

### Multi-Region Setup
- Use Route 53 for failover routing
- Implement cross-region replication
- Regular DR testing

## 📊 Performance Optimization

### EC2 Performance
- Use EBS optimized instances
- Monitor and adjust Auto Scaling
- Implement proper instance sizing

### Database Optimization
- Use read replicas effectively
- Implement connection pooling
- Regular maintenance windows

## Hidden Gems

1. Use AWS Systems Manager Parameter Store for configuration
2. Implement AWS Config for compliance monitoring
3. Use AWS CDK for infrastructure as actual code
4. Leverage EventBridge for event-driven architectures
5. Use AWS Service Quotas API for limit monitoring

## DevOps Best Practices

1. **Infrastructure as Code**
   - Version control all templates
   - Use nested stacks for reusability
   - Implement proper state management

2. **Monitoring & Alerting**
   - Set up comprehensive dashboards
   - Use composite alarms
   - Implement proper log aggregation

3. **Security**
   - Regular security assessments
   - Implement WAF rules
   - Use AWS Security Hub

4. **Cost Management**
   - Regular cost analysis
   - Implement auto-scaling policies
   - Use cost allocation tags

5. **Automation**
   - Automate routine tasks
   - Use AWS Step Functions
   - Implement CI/CD pipelines