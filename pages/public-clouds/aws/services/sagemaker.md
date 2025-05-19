# Amazon SageMaker

## Overview
Amazon SageMaker is a fully managed service for building, training, and deploying machine learning models at scale.

## Real-life Use Cases
- **Cloud Architect:** Design end-to-end ML pipelines for production workloads.
- **DevOps Engineer:** Automate model deployment and monitoring.

## Terraform Example
```hcl
resource "aws_sagemaker_notebook_instance" "ml_notebook" {
  name          = "ml-notebook"
  instance_type = "ml.t2.medium"
  role_arn      = aws_iam_role.sagemaker_execution.arn
}
```

## AWS CLI Example
```sh
aws sagemaker create-notebook-instance --notebook-instance-name ml-notebook --instance-type ml.t2.medium --role-arn arn:aws:iam::123456789012:role/SageMakerExecutionRole
```

## Best Practices
- Use lifecycle configurations for automation.
- Monitor model drift and retrain as needed.

## Common Pitfalls
- Not securing notebook endpoints.
- Underestimating storage needs for training data.

> **Joke:** Why did the ML model go to SageMaker? To get some training!
