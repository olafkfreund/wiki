---
description: Amazon Elastic Container Service (ECS) - Fully managed container orchestration service on AWS
---

# Amazon ECS (Elastic Container Service)

## Overview

Amazon Elastic Container Service (ECS) is a fully managed container orchestration service that makes it easy to deploy, manage, and scale containerized applications. As of May 2025, ECS supports Docker containers and integrates with a range of AWS services to provide a comprehensive platform for running applications without managing the underlying infrastructure.

ECS offers two launch types: EC2 for more control over your infrastructure, and Fargate for serverless container deployments.

## Key Concepts

### ECS Core Components
- **Cluster**: Logical grouping of tasks or services
- **Task Definition**: Blueprint for your application that specifies containers, CPU, memory, and networking
- **Task**: Instance of a task definition running on a cluster
- **Service**: Ensures a specified number of tasks are running at all times
- **Container Instance**: EC2 instance running the ECS agent (EC2 launch type only)
- **Capacity Provider**: Infrastructure management strategy for your cluster (EC2 or Fargate)

### ECS Launch Types
- **EC2 Launch Type**: Containers run on EC2 instances that you manage
- **Fargate Launch Type**: Serverless option where AWS manages the underlying infrastructure
- **External Launch Type**: Run ECS tasks on your own servers or VMs

### ECS Networking
- **awsvpc Mode**: Each task gets its own ENI and security group
- **bridge Mode**: Docker's default networking mode (EC2 launch type only)
- **host Mode**: Containers use the host's network interface (EC2 launch type only)
- **VPC Endpoints**: Private connectivity to AWS services

## Deploying ECS with Terraform

### Basic ECS Cluster with Fargate

```hcl
provider "aws" {
  region = "us-west-2"
}

# Create a VPC for ECS
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"
  
  name = "ecs-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  
  tags = {
    Environment = "production"
  }
}

# Create an ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "app-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = {
    Environment = "production"
  }
}

# Create an ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create a task definition
resource "aws_ecs_task_definition" "app" {
  family                   = "app-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  
  container_definitions = jsonencode([
    {
      name      = "app-container"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/app-task"
          "awslogs-region"        = "us-west-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  
  tags = {
    Environment = "production"
    Application = "app"
  }
}

# Create a CloudWatch log group
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/ecs/app-task"
  retention_in_days = 30
  
  tags = {
    Environment = "production"
    Application = "app"
  }
}

# Create a security group for the ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-sg"
  description = "Allow inbound traffic to ECS tasks"
  vpc_id      = module.vpc.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Environment = "production"
  }
}

# Create an ECS service
resource "aws_ecs_service" "app" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app-container"
    container_port   = 80
  }
  
  depends_on = [aws_lb_listener.app]
  
  tags = {
    Environment = "production"
    Application = "app"
  }
}

# Create an Application Load Balancer
resource "aws_lb" "app" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = module.vpc.public_subnets
  
  enable_deletion_protection = false
  
  tags = {
    Environment = "production"
  }
}

# Create a security group for the load balancer
resource "aws_security_group" "lb" {
  name        = "alb-sg"
  description = "Allow inbound traffic to ALB"
  vpc_id      = module.vpc.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Environment = "production"
  }
}

# Create a target group for the load balancer
resource "aws_lb_target_group" "app" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  target_type = "ip"
  
  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }
}

# Create a listener for the load balancer
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}
```

### ECS with EC2 Launch Type

```hcl
# Create an Auto Scaling Group for ECS
resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "ecs-launch-template-"
  image_id      = "ami-0f07478f5c5a9a9d9"  # Amazon ECS-optimized AMI ID (check for latest)
  instance_type = "t3.medium"
  
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }
  
  vpc_security_group_ids = [aws_security_group.ecs_instances.id]
  
  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
EOF
  )
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                = "ecs-asg"
  vpc_zone_identifier = module.vpc.private_subnets
  min_size            = 2
  max_size            = 10
  desired_capacity    = 2
  
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }
  
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "ec2_capacity_provider" {
  name = "ec2-capacity-provider"
  
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn
    
    managed_scaling {
      maximum_scaling_step_size = 100
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 70
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.main.name
  
  capacity_providers = [aws_ecs_capacity_provider.ec2_capacity_provider.name]
  
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2_capacity_provider.name
    weight            = 1
  }
}

resource "aws_security_group" "ecs_instances" {
  name        = "ecs-instances-sg"
  description = "Security group for ECS instances"
  vpc_id      = module.vpc.vpc_id
  
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Deploying ECS with AWS CLI

### Prerequisites
Before you begin, ensure you have:
- AWS CLI (version 2.13.0 or higher) installed and configured
- Docker installed (for building and pushing images)
- Appropriate IAM permissions for ECS operations

### 1. Create an ECS Cluster

```bash
# Create a simple ECS cluster
aws ecs create-cluster \
  --cluster-name app-cluster \
  --settings name=containerInsights,value=enabled

# View clusters
aws ecs list-clusters
```

### 2. Register a Task Definition

First, create a task definition JSON file:

```bash
cat > task-definition.json << EOF
{
  "family": "app-task",
  "executionRoleArn": "arn:aws:iam::<YOUR_ACCOUNT_ID>:role/ecsTaskExecutionRole",
  "networkMode": "awsvpc",
  "containerDefinitions": [
    {
      "name": "app-container",
      "image": "nginx:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/app-task",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ],
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "cpu": "256",
  "memory": "512"
}
EOF

# Register the task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json

# List task definitions
aws ecs list-task-definitions
```

### 3. Create a CloudWatch Log Group

```bash
aws logs create-log-group --log-group-name /ecs/app-task
```

### 4. Create a Service

```bash
# Create the ECS service
aws ecs create-service \
  --cluster app-cluster \
  --service-name app-service \
  --task-definition app-task \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345,subnet-67890],securityGroups=[sg-12345],assignPublicIp=DISABLED}" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:us-west-2:<YOUR_ACCOUNT_ID>:targetgroup/app-target-group/1234567890,containerName=app-container,containerPort=80"
```

### 5. Run a Standalone Task

```bash
aws ecs run-task \
  --cluster app-cluster \
  --task-definition app-task \
  --count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345,subnet-67890],securityGroups=[sg-12345],assignPublicIp=ENABLED}"
```

### 6. List Running Tasks and Services

```bash
# List services in a cluster
aws ecs list-services --cluster app-cluster

# Describe a service
aws ecs describe-services --cluster app-cluster --services app-service

# List tasks
aws ecs list-tasks --cluster app-cluster

# Describe a task
aws ecs describe-tasks --cluster app-cluster --tasks task-id
```

### 7. Update a Service

```bash
# Scale a service
aws ecs update-service \
  --cluster app-cluster \
  --service app-service \
  --desired-count 3

# Update a service to use a new task definition
aws ecs update-service \
  --cluster app-cluster \
  --service app-service \
  --task-definition app-task:2  # new version of the task definition
```

### 8. Set up Auto Scaling for a Service

```bash
# Register a scalable target
aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --resource-id service/app-cluster/app-service \
  --scalable-dimension ecs:service:DesiredCount \
  --min-capacity 2 \
  --max-capacity 10

# Create a step scaling policy
aws application-autoscaling put-scaling-policy \
  --service-namespace ecs \
  --resource-id service/app-cluster/app-service \
  --scalable-dimension ecs:service:DesiredCount \
  --policy-name cpu-tracking-scaling-policy \
  --policy-type TargetTrackingScaling \
  --target-tracking-scaling-policy-configuration '{
    "TargetValue": 70.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
    },
    "ScaleOutCooldown": 60,
    "ScaleInCooldown": 60
  }'
```

### 9. Clean Up

```bash
# Delete a service
aws ecs update-service --cluster app-cluster --service app-service --desired-count 0
aws ecs delete-service --cluster app-cluster --service app-service

# Delete a cluster
aws ecs delete-cluster --cluster app-cluster
```

## ECS with EC2 Launch Type using AWS CLI

### 1. Create an EC2 Instance Role

```bash
# Create IAM role policy document
cat > ecs-instance-role-trust.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create IAM role
aws iam create-role \
  --role-name ecsInstanceRole \
  --assume-role-policy-document file://ecs-instance-role-trust.json

# Attach policy to role
aws iam attach-role-policy \
  --role-name ecsInstanceRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role

# Create an instance profile
aws iam create-instance-profile \
  --instance-profile-name ecsInstanceProfile

# Add role to instance profile
aws iam add-role-to-instance-profile \
  --instance-profile-name ecsInstanceProfile \
  --role-name ecsInstanceRole
```

### 2. Launch EC2 Instances with ECS Agent

```bash
# Create a security group for the ECS instances
aws ec2 create-security-group \
  --group-name ecs-instances \
  --description "Security group for ECS instances" \
  --vpc-id vpc-12345

# Add inbound rule
aws ec2 authorize-security-group-ingress \
  --group-id sg-12345 \
  --protocol tcp \
  --port 80 \
  --source-group sg-loadbalancer

# Launch EC2 instance with ECS agent
aws ec2 run-instances \
  --image-id ami-0f07478f5c5a9a9d9 \  # Amazon ECS-optimized AMI
  --instance-type t3.medium \
  --key-name my-key-pair \
  --security-group-ids sg-12345 \
  --subnet-id subnet-12345 \
  --iam-instance-profile Name=ecsInstanceProfile \
  --user-data "#!/bin/bash
echo ECS_CLUSTER=app-cluster >> /etc/ecs/ecs.config"
```

### 3. Create a Capacity Provider

First, set up an Auto Scaling Group:

```bash
# Create a launch configuration
aws autoscaling create-launch-configuration \
  --launch-configuration-name ecs-launch-config \
  --image-id ami-0f07478f5c5a9a9d9 \  # Amazon ECS-optimized AMI
  --instance-type t3.medium \
  --security-groups sg-12345 \
  --iam-instance-profile ecsInstanceProfile \
  --user-data "#!/bin/bash
echo ECS_CLUSTER=app-cluster >> /etc/ecs/ecs.config"

# Create an Auto Scaling Group
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name ecs-asg \
  --launch-configuration-name ecs-launch-config \
  --min-size 2 \
  --max-size 10 \
  --desired-capacity 2 \
  --vpc-zone-identifier "subnet-12345,subnet-67890" \
  --tags "Key=AmazonECSManaged,Value=true,PropagateAtLaunch=true"
```

Then create the capacity provider:

```bash
# Create the capacity provider
aws ecs create-capacity-provider \
  --name ec2-capacity-provider \
  --auto-scaling-group-provider "autoScalingGroupArn=arn:aws:autoscaling:us-west-2:<YOUR_ACCOUNT_ID>:autoScalingGroup:1234:autoScalingGroupName/ecs-asg,managedScaling={status=ENABLED,targetCapacity=70,minimumScalingStepSize=1,maximumScalingStepSize=100},managedTerminationProtection=DISABLED"

# Associate with the cluster
aws ecs put-cluster-capacity-providers \
  --cluster app-cluster \
  --capacity-providers ec2-capacity-provider \
  --default-capacity-provider-strategy "capacityProvider=ec2-capacity-provider,weight=1"
```

### 4. Create a Service with EC2 Launch Type

```bash
aws ecs create-service \
  --cluster app-cluster \
  --service-name app-service-ec2 \
  --task-definition app-task \
  --desired-count 2 \
  --capacity-provider-strategy "capacityProvider=ec2-capacity-provider,weight=1" \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345,subnet-67890],securityGroups=[sg-12345]}" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:us-west-2:<YOUR_ACCOUNT_ID>:targetgroup/app-target-group/1234567890,containerName=app-container,containerPort=80"
```

## Best Practices for ECS

1. **Security**
   - Use IAM roles for tasks to provide least-privilege permissions
   - Implement security groups for your containers
   - Keep your ECS Agent updated
   - Use secrets management with AWS Secrets Manager or Parameter Store

2. **Cost Optimization**
   - Choose the right launch type for your workload (EC2 vs. Fargate)
   - Use Spot capacity providers for non-critical or batch workloads
   - Implement auto-scaling to match capacity with demand
   - Consider Compute Savings Plans for Fargate usage

3. **Performance and Scalability**
   - Use Application Load Balancers for HTTP/HTTPS applications
   - Implement service auto-scaling based on appropriate metrics
   - Optimize container images for faster launches
   - Use Service Discovery for service-to-service communication

4. **Reliability**
   - Deploy across multiple availability zones
   - Use containerized health checks
   - Implement task placement strategies and constraints
   - Use deployment circuit breaker to prevent failed deployments

5. **Monitoring and Observability**
   - Enable Container Insights
   - Use structured logging with CloudWatch Logs
   - Set up appropriate CloudWatch alarms
   - Implement X-Ray for distributed tracing

## Reference Links

- [AWS ECS Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)
- [ECS API Reference](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/Welcome.html)
- [ECS AWS CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/ecs/index.html)
- [ECS Best Practices Guide](https://aws.github.io/aws-ecs-best-practices)