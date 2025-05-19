# Amazon SQS (Simple Queue Service)

## Overview
Amazon SQS is a fully managed message queuing service for decoupling and scaling microservices, distributed systems, and serverless apps.

## Real-life Use Cases
- **Cloud Architect:** Design asynchronous workflows for order processing.
- **DevOps Engineer:** Buffer jobs for batch processing pipelines.

## Terraform Example
```hcl
resource "aws_sqs_queue" "job_queue" {
  name = "job-queue"
}
```

## AWS CLI Example
```sh
aws sqs create-queue --queue-name job-queue
```

## Best Practices
- Use dead-letter queues for failed messages.
- Set appropriate visibility timeouts.

## Common Pitfalls
- Not handling message duplication.
- Ignoring queue length metrics.

> **Joke:** Why did the SQS message get lost? It took the wrong queue!
