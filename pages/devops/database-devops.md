# Database DevOps (2024+)

## Version Control and Migration

### Flyway Implementation

```sql
-- V1__initial_schema.sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- V2__add_user_status.sql
ALTER TABLE users ADD COLUMN status VARCHAR(50) DEFAULT 'active';
```

### Automated Testing

```yaml
# Database CI pipeline
name: Database CI
on: [pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
    steps:
      - uses: actions/checkout@v4
      - name: Run migrations
        run: flyway migrate
      - name: Run tests
        run: go test ./...
```

## Modern Practices

### Database as Code

* Schema version control
* Migration automation
* State management
* Rollback procedures

### Testing Strategy

* Schema validation
* Migration testing
* Performance testing
* Data integrity checks

### Security Controls

* Access management
* Audit logging
* Encryption
* Compliance checks

## Cloud Integration

### Multi-Cloud Database Operations

* AWS RDS automation
* Azure Database automation
* GCP Cloud SQL automation
* Cross-cloud replication

### Infrastructure Definition

```hcl
resource "aws_rds_cluster" "aurora" {
  cluster_identifier  = "app-${var.environment}"
  engine             = "aurora-postgresql"
  engine_version     = "15.3"
  master_username    = data.aws_secretsmanager_secret_version.db_creds.username
  master_password    = data.aws_secretsmanager_secret_version.db_creds.password
  backup_retention_period = 7
  
  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 4.0
  }
}
```

## Observability

### Monitoring Setup

* Performance metrics
* Query analysis
* Resource utilization
* Alert configuration

### Automated Responses

* Scaling operations
* Backup verification
* Incident response
* Recovery procedures
