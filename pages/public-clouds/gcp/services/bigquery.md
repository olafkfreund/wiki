---
description: Deploying and managing Google BigQuery for enterprise data analytics
---

# BigQuery

Google BigQuery is a fully-managed, serverless data warehouse that enables super-fast SQL queries using the processing power of Google's infrastructure. It allows you to analyze large datasets with high performance and cost efficiency.

## Key Features

- **Serverless**: No infrastructure to manage or provision
- **Petabyte Scale**: Query petabytes of data with ease
- **Separation of Storage and Compute**: Pay only for the storage you use and the queries you run
- **Real-time Analytics**: Stream data for real-time analysis and ML
- **Geospatial Analysis**: Built-in support for geographic data types
- **ML Integration**: Train and run ML models directly using SQL with BigQuery ML
- **BI Engine**: In-memory analysis service for sub-second query response
- **Federated Queries**: Query data from external sources without copying
- **Data Governance**: Column-level security and dynamic data masking
- **Cost Controls**: Custom quotas and intelligent pricing models

## Deploying BigQuery with Terraform

### Basic Dataset and Table Creation

```hcl
resource "google_bigquery_dataset" "default" {
  dataset_id                  = "example_dataset"
  friendly_name               = "test"
  description                 = "This is a test dataset"
  location                    = "US"
  default_table_expiration_ms = 3600000  # 1 hour
  
  labels = {
    env = "default"
  }
  
  access {
    role          = "OWNER"
    user_by_email = google_service_account.bq_admin.email
  }
  
  access {
    role          = "READER"
    group_by_email = "analytics-team@example.com"
  }
}

resource "google_service_account" "bq_admin" {
  account_id   = "bq-admin"
  display_name = "BigQuery Administrator"
}

resource "google_bigquery_table" "default" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "example_table"
  
  time_partitioning {
    type = "DAY"
    field = "timestamp"
  }
  
  clustering = ["customer_id", "region"]
  
  schema = <<EOF
[
  {
    "name": "customer_id",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Customer identifier"
  },
  {
    "name": "timestamp",
    "type": "TIMESTAMP",
    "mode": "REQUIRED",
    "description": "Event timestamp"
  },
  {
    "name": "region",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Customer region"
  },
  {
    "name": "amount",
    "type": "FLOAT",
    "mode": "NULLABLE",
    "description": "Transaction amount"
  }
]
EOF

  deletion_protection = false
}
```

### Advanced Configuration with Authorized Views and Row-Level Security

```hcl
resource "google_bigquery_dataset" "sensitive_data" {
  dataset_id                  = "sensitive_data"
  friendly_name               = "Sensitive Data"
  description                 = "Contains PII and other sensitive information"
  location                    = "US"
  
  # Enable CMEK (Customer Managed Encryption Keys)
  default_encryption_configuration {
    kms_key_name = google_kms_crypto_key.bq_key.id
  }
  
  # Set access controls
  access {
    role          = "OWNER"
    user_by_email = google_service_account.bq_admin.email
  }
  
  # No direct access for analysts
}

# Create an authorized view dataset
resource "google_bigquery_dataset" "authorized_views" {
  dataset_id                  = "authorized_views"
  friendly_name               = "Authorized Views"
  description                 = "Contains secured views for analysts"
  location                    = "US"
  
  access {
    role          = "OWNER"
    user_by_email = google_service_account.bq_admin.email
  }
  
  access {
    role          = "READER"
    group_by_email = "analysts@example.com"
  }
}

# Create a KMS key for encryption
resource "google_kms_key_ring" "bigquery" {
  name     = "bigquery-keyring"
  location = "global"
}

resource "google_kms_crypto_key" "bq_key" {
  name     = "bigquery-key"
  key_ring = google_kms_key_ring.bigquery.id
}

# Grant BigQuery service account access to the KMS key
data "google_project" "project" {}

resource "google_kms_crypto_key_iam_member" "crypto_key" {
  crypto_key_id = google_kms_crypto_key.bq_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:bq-${data.google_project.project.number}@bigquery-encryption.iam.gserviceaccount.com"
}

# Create sensitive data table
resource "google_bigquery_table" "customer_data" {
  dataset_id = google_bigquery_dataset.sensitive_data.dataset_id
  table_id   = "customer_data"
  
  schema = <<EOF
[
  {
    "name": "customer_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "full_name",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "email",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "address",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "date_of_birth",
    "type": "DATE",
    "mode": "NULLABLE"
  },
  {
    "name": "region",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "customer_type",
    "type": "STRING",
    "mode": "NULLABLE"
  }
]
EOF

  # Apply row access policy (defined later)
  deletion_protection = true
}

# Create authorized view
resource "google_bigquery_table" "customer_view" {
  dataset_id = google_bigquery_dataset.authorized_views.dataset_id
  table_id   = "customer_view"
  view {
    query = <<EOF
      SELECT 
        customer_id,
        CONCAT(SUBSTR(full_name, 1, 1), '***') AS masked_name,
        REGEXP_REPLACE(email, r'(.+)@(.+)', r'****@\\2') AS masked_email,
        region,
        customer_type
      FROM 
        ${google_bigquery_dataset.sensitive_data.dataset_id}.${google_bigquery_table.customer_data.table_id}
    EOF
    use_legacy_sql = false
  }
  
  deletion_protection = true
}

# Grant view access to the underlying table
resource "google_bigquery_dataset_access" "authorized_view_access" {
  dataset_id    = google_bigquery_dataset.sensitive_data.dataset_id
  view {
    project_id = data.google_project.project.project_id
    dataset_id = google_bigquery_dataset.authorized_views.dataset_id
    table_id   = google_bigquery_table.customer_view.table_id
  }
}

# Create a row access policy for region-based filtering
resource "google_bigquery_table_iam_policy" "policy" {
  project    = data.google_project.project.project_id
  dataset_id = google_bigquery_dataset.sensitive_data.dataset_id
  table_id   = google_bigquery_table.customer_data.table_id
  
  policy_data = data.google_iam_policy.row_access_policy.policy_data
}

data "google_iam_policy" "row_access_policy" {
  binding {
    role = "roles/bigquery.dataViewer"
    
    members = [
      "group:us-analysts@example.com",
    ]
    
    condition {
      title       = "US Region Access Only"
      description = "Only allows access to US region data"
      expression  = "resource.region == \"US\""
    }
  }
  
  binding {
    role = "roles/bigquery.dataViewer"
    
    members = [
      "group:eu-analysts@example.com",
    ]
    
    condition {
      title       = "EU Region Access Only"
      description = "Only allows access to EU region data"
      expression  = "resource.region == \"EU\""
    }
  }
}
```

## Managing BigQuery with gcloud CLI

### Creating Datasets and Tables

```bash
# Create a dataset
gcloud bq mk \
  --dataset \
  --description="Sales analytics dataset" \
  --location=US \
  your-project-id:sales_analytics

# Create a table with schema
gcloud bq mk \
  --table \
  --schema="transaction_id:STRING,customer_id:STRING,product_id:STRING,quantity:INTEGER,price:FLOAT,timestamp:TIMESTAMP" \
  your-project-id:sales_analytics.transactions

# Load data into a table from Cloud Storage
gcloud bq load \
  --source_format=CSV \
  --skip_leading_rows=1 \
  your-project-id:sales_analytics.transactions \
  gs://your-bucket/sales-data/transactions.csv \
  transaction_id:STRING,customer_id:STRING,product_id:STRING,quantity:INTEGER,price:FLOAT,timestamp:TIMESTAMP
```

### Running Queries

```bash
# Run a simple query
gcloud bq query \
  --use_legacy_sql=false \
  'SELECT COUNT(*) as transaction_count FROM `your-project-id.sales_analytics.transactions`'

# Run a query and save results to a table
gcloud bq query \
  --use_legacy_sql=false \
  --destination_table=sales_analytics.daily_summary \
  --append_table \
  'SELECT 
     DATE(timestamp) as date, 
     COUNT(*) as transactions, 
     SUM(price * quantity) as revenue 
   FROM 
     `your-project-id.sales_analytics.transactions` 
   GROUP BY 
     date 
   ORDER BY 
     date DESC'

# Export query results to Cloud Storage
gcloud bq extract \
  your-project-id:sales_analytics.daily_summary \
  gs://your-bucket/exports/daily_summary.csv
```

### Managing Permissions

```bash
# Grant dataset access
gcloud bq add-iam-policy-binding \
  --dataset=your-project-id:sales_analytics \
  --member=user:user@example.com \
  --role=roles/bigquery.dataViewer

# Grant table access
gcloud bq add-iam-policy-binding \
  --table=your-project-id:sales_analytics.transactions \
  --member=serviceAccount:etl-service@your-project-id.iam.gserviceaccount.com \
  --role=roles/bigquery.dataEditor

# View current IAM policy for a dataset
gcloud bq get-iam-policy \
  --dataset=your-project-id:sales_analytics
```

## Real-World Example: E-commerce Analytics Platform

This example demonstrates a complete data analytics platform for an e-commerce company:

### Step 1: Infrastructure Setup with Terraform

```hcl
# Create datasets for different layers of the data platform
resource "google_bigquery_dataset" "raw_data" {
  dataset_id                  = "raw_data"
  friendly_name               = "Raw Data"
  description                 = "Landing zone for raw data"
  location                    = "US"
  default_table_expiration_ms = 7776000000  # 90 days
  
  labels = {
    environment = "production"
    data_type   = "raw"
  }
}

resource "google_bigquery_dataset" "staging" {
  dataset_id                  = "staging"
  friendly_name               = "Staging"
  description                 = "Intermediate processing zone"
  location                    = "US"
  default_table_expiration_ms = 2592000000  # 30 days
  
  labels = {
    environment = "production"
    data_type   = "staging"
  }
}

resource "google_bigquery_dataset" "data_warehouse" {
  dataset_id                  = "data_warehouse"
  friendly_name               = "Data Warehouse"
  description                 = "Enterprise data warehouse"
  location                    = "US"
  
  labels = {
    environment = "production"
    data_type   = "curated"
  }
}

resource "google_bigquery_dataset" "data_marts" {
  dataset_id                  = "data_marts"
  friendly_name               = "Data Marts"
  description                 = "Business-specific data marts"
  location                    = "US"
  
  labels = {
    environment = "production"
    data_type   = "marts"
  }
}

# Create raw tables
resource "google_bigquery_table" "raw_transactions" {
  dataset_id = google_bigquery_dataset.raw_data.dataset_id
  table_id   = "transactions"
  
  time_partitioning {
    type  = "DAY"
    field = "transaction_date"
  }
  
  schema = <<EOF
[
  {
    "name": "transaction_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "transaction_date",
    "type": "TIMESTAMP",
    "mode": "REQUIRED"
  },
  {
    "name": "customer_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "product_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "quantity",
    "type": "INTEGER",
    "mode": "REQUIRED"
  },
  {
    "name": "unit_price",
    "type": "FLOAT",
    "mode": "REQUIRED"
  },
  {
    "name": "total_amount",
    "type": "FLOAT",
    "mode": "REQUIRED"
  },
  {
    "name": "payment_method",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "store_id",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "json_payload",
    "type": "JSON",
    "mode": "NULLABLE"
  }
]
EOF
}

resource "google_bigquery_table" "raw_customers" {
  dataset_id = google_bigquery_dataset.raw_data.dataset_id
  table_id   = "customers"
  
  schema = <<EOF
[
  {
    "name": "customer_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "first_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "last_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "email",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "phone",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "address",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "city",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "state",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "country",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "zip_code",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "registration_date",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  }
]
EOF
}

resource "google_bigquery_table" "raw_products" {
  dataset_id = google_bigquery_dataset.raw_data.dataset_id
  table_id   = "products"
  
  schema = <<EOF
[
  {
    "name": "product_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "product_name",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "category",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "subcategory",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "brand",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "supplier_id",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "base_price",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "tax_rate",
    "type": "FLOAT",
    "mode": "NULLABLE"
  }
]
EOF
}

# Create warehouse fact and dimension tables
resource "google_bigquery_table" "fact_sales" {
  dataset_id = google_bigquery_dataset.data_warehouse.dataset_id
  table_id   = "fact_sales"
  
  time_partitioning {
    type  = "DAY"
    field = "transaction_date"
  }
  
  clustering = ["customer_id", "product_id", "store_id"]
  
  schema = <<EOF
[
  {
    "name": "transaction_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "transaction_date",
    "type": "DATE",
    "mode": "REQUIRED"
  },
  {
    "name": "transaction_time",
    "type": "TIME",
    "mode": "REQUIRED"
  },
  {
    "name": "customer_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "product_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "store_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "quantity",
    "type": "INTEGER",
    "mode": "REQUIRED"
  },
  {
    "name": "unit_price",
    "type": "FLOAT",
    "mode": "REQUIRED"
  },
  {
    "name": "net_amount",
    "type": "FLOAT",
    "mode": "REQUIRED"
  },
  {
    "name": "tax_amount",
    "type": "FLOAT",
    "mode": "REQUIRED"
  },
  {
    "name": "total_amount",
    "type": "FLOAT",
    "mode": "REQUIRED"
  },
  {
    "name": "payment_method",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "is_online",
    "type": "BOOLEAN",
    "mode": "REQUIRED"
  }
]
EOF
}

resource "google_bigquery_table" "dim_customer" {
  dataset_id = google_bigquery_dataset.data_warehouse.dataset_id
  table_id   = "dim_customer"
  
  schema = <<EOF
[
  {
    "name": "customer_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "first_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "last_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "full_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "email",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "city",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "state",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "country",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "zip_code",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "registration_date",
    "type": "DATE",
    "mode": "NULLABLE"
  },
  {
    "name": "customer_segment",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "valid_from",
    "type": "TIMESTAMP",
    "mode": "REQUIRED"
  },
  {
    "name": "valid_to",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "is_current",
    "type": "BOOLEAN",
    "mode": "REQUIRED"
  }
]
EOF
}

# Create data mart views
resource "google_bigquery_table" "sales_mart_monthly" {
  dataset_id = google_bigquery_dataset.data_marts.dataset_id
  table_id   = "sales_by_month"
  
  view {
    query = <<EOF
      SELECT 
        EXTRACT(YEAR FROM transaction_date) AS year,
        EXTRACT(MONTH FROM transaction_date) AS month,
        SUM(quantity) AS total_units_sold,
        SUM(total_amount) AS total_revenue,
        COUNT(DISTINCT transaction_id) AS transaction_count,
        COUNT(DISTINCT customer_id) AS unique_customers
      FROM 
        `${google_bigquery_dataset.data_warehouse.dataset_id}.${google_bigquery_table.fact_sales.table_id}`
      GROUP BY 
        year, month
      ORDER BY 
        year DESC, month DESC
    EOF
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "customer_lifetime_value" {
  dataset_id = google_bigquery_dataset.data_marts.dataset_id
  table_id   = "customer_lifetime_value"
  
  view {
    query = <<EOF
      WITH customer_purchases AS (
        SELECT 
          fs.customer_id,
          dc.full_name,
          dc.registration_date,
          SUM(fs.total_amount) AS lifetime_value,
          MIN(fs.transaction_date) AS first_purchase_date,
          MAX(fs.transaction_date) AS last_purchase_date,
          COUNT(DISTINCT fs.transaction_id) AS total_purchases,
          DATE_DIFF(CURRENT_DATE(), MIN(fs.transaction_date), DAY) AS days_since_first_purchase,
          DATE_DIFF(CURRENT_DATE(), MAX(fs.transaction_date), DAY) AS days_since_last_purchase
        FROM 
          `${google_bigquery_dataset.data_warehouse.dataset_id}.${google_bigquery_table.fact_sales.table_id}` fs
        JOIN
          `${google_bigquery_dataset.data_warehouse.dataset_id}.${google_bigquery_table.dim_customer.table_id}` dc
        ON 
          fs.customer_id = dc.customer_id AND dc.is_current = TRUE
        GROUP BY 
          fs.customer_id, dc.full_name, dc.registration_date
      )
      
      SELECT 
        customer_id,
        full_name,
        registration_date,
        lifetime_value,
        total_purchases,
        lifetime_value / total_purchases AS avg_order_value,
        first_purchase_date,
        last_purchase_date,
        days_since_first_purchase,
        days_since_last_purchase,
        CASE 
          WHEN days_since_last_purchase <= 30 THEN 'Active'
          WHEN days_since_last_purchase BETWEEN 31 AND 90 THEN 'At Risk'
          WHEN days_since_last_purchase BETWEEN 91 AND 365 THEN 'Lapsed'
          ELSE 'Inactive'
        END AS customer_status
      FROM 
        customer_purchases
      ORDER BY 
        lifetime_value DESC
    EOF
    use_legacy_sql = false
  }
}

# Set up scheduled query for daily ETL
resource "google_bigquery_data_transfer_config" "daily_etl" {
  display_name           = "Daily ETL pipeline"
  location               = "US"
  data_source_id         = "scheduled_query"
  schedule               = "every 24 hours"
  destination_dataset_id = google_bigquery_dataset.data_warehouse.dataset_id
  
  params = {
    query = <<EOF
      -- Refresh fact_sales table with new data
      DELETE FROM `${google_bigquery_dataset.data_warehouse.dataset_id}.${google_bigquery_table.fact_sales.table_id}` 
      WHERE DATE(transaction_date) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY);
      
      INSERT INTO `${google_bigquery_dataset.data_warehouse.dataset_id}.${google_bigquery_table.fact_sales.table_id}`
      SELECT 
        transaction_id,
        DATE(transaction_date) AS transaction_date,
        TIME(transaction_date) AS transaction_time,
        customer_id,
        product_id,
        store_id,
        quantity,
        unit_price,
        (quantity * unit_price) AS net_amount,
        (quantity * unit_price * p.tax_rate) AS tax_amount,
        total_amount,
        payment_method,
        IFNULL(store_id = 'ONLINE', FALSE) AS is_online
      FROM 
        `${google_bigquery_dataset.raw_data.dataset_id}.${google_bigquery_table.raw_transactions.table_id}` t
      JOIN
        `${google_bigquery_dataset.raw_data.dataset_id}.${google_bigquery_table.raw_products.table_id}` p
      ON
        t.product_id = p.product_id
      WHERE
        DATE(transaction_date) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY);
    EOF
  }

  service_account_name = google_service_account.bigquery_etl.email
}

# Service account for ETL operations
resource "google_service_account" "bigquery_etl" {
  account_id   = "bigquery-etl"
  display_name = "BigQuery ETL Service Account"
}

# Grant necessary permissions
resource "google_project_iam_member" "etl_permissions" {
  for_each = toset([
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser"
  ])
  
  role    = each.key
  member  = "serviceAccount:${google_service_account.bigquery_etl.email}"
  project = data.google_project.project.project_id
}

# Get project information
data "google_project" "project" {}
```

### Step 2: Set up Data Loading Pipelines

Create a Cloud Function to load data from various sources into BigQuery:

```python
# main.py
import json
import base64
import pandas as pd
from google.cloud import bigquery
from google.cloud import storage

# Initialize clients
bigquery_client = bigquery.Client()
storage_client = storage.Client()

def process_transaction_data(event, context):
    """Cloud Function triggered by a Pub/Sub event"""
    # Decode the Pub/Sub message
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    message_data = json.loads(pubsub_message)
    
    # Get source file details
    bucket_name = message_data['bucket']
    file_name = message_data['file']
    
    # Set up the job configuration
    job_config = bigquery.LoadJobConfig(
        schema=[
            bigquery.SchemaField("transaction_id", "STRING"),
            bigquery.SchemaField("transaction_date", "TIMESTAMP"),
            bigquery.SchemaField("customer_id", "STRING"),
            bigquery.SchemaField("product_id", "STRING"),
            bigquery.SchemaField("quantity", "INTEGER"),
            bigquery.SchemaField("unit_price", "FLOAT"),
            bigquery.SchemaField("total_amount", "FLOAT"),
            bigquery.SchemaField("payment_method", "STRING"),
            bigquery.SchemaField("store_id", "STRING"),
            bigquery.SchemaField("json_payload", "JSON"),
        ],
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,
    )
    
    # Get the table reference
    table_id = f"{message_data['project_id']}.raw_data.transactions"
    
    # Create a job to load data from GCS to BigQuery
    uri = f"gs://{bucket_name}/{file_name}"
    load_job = bigquery_client.load_table_from_uri(
        uri, table_id, job_config=job_config
    )
    
    # Wait for the job to complete
    load_job.result()
    
    # Get statistics
    table = bigquery_client.get_table(table_id)
    print(f"Loaded {load_job.output_rows} rows into {table_id}")
    
    return f"Loaded {load_job.output_rows} rows into {table_id}"
```

### Step 3: Create Business Intelligence Dashboard using Looker Studio

1. Set up a connection to BigQuery data marts
2. Create a dashboard that pulls from the data marts:

```sql
-- Example query for sales dashboard
SELECT 
  d.year,
  d.month,
  FORMAT_DATETIME('%b %Y', DATE(d.year, d.month, 1)) AS month_year,
  c.category,
  SUM(s.total_revenue) AS revenue,
  SUM(s.total_units_sold) AS units_sold,
  SUM(s.transaction_count) AS transactions,
  SUM(s.unique_customers) AS customers
FROM 
  `your-project-id.data_marts.sales_by_month` s
JOIN 
  `your-project-id.data_warehouse.dim_date` d ON (s.year = d.year AND s.month = d.month)
JOIN 
  `your-project-id.data_warehouse.dim_product` p ON s.product_id = p.product_id
JOIN 
  `your-project-id.data_warehouse.dim_category` c ON p.category_id = c.category_id
WHERE 
  d.date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
GROUP BY 
  d.year, d.month, month_year, c.category
ORDER BY 
  d.year, d.month, c.category
```

## Best Practices

1. **Data Organization**
   - Structure data in datasets by function (raw, staging, production)
   - Use consistent naming conventions for datasets and tables
   - Consider data lifecycle management with table expiration
   - Implement a multi-layer architecture (bronze, silver, gold)

2. **Performance Optimization**
   - Partition tables by date fields for time-series data
   - Apply clustering for frequently filtered fields
   - Use materialized views for common query patterns
   - Consider BigQuery BI Engine for dashboarding workloads
   - Write efficient SQL (avoid SELECT * and unnecessary JOINs)

3. **Cost Management**
   - Set up billing alerts and quotas
   - Use flat-rate pricing for predictable workloads
   - Apply table partitioning to reduce scan sizes
   - Cache query results when possible
   - Consider reservations for consistent usage

4. **Security and Governance**
   - Implement column-level security for sensitive data
   - Use authorized views to control access to underlying data
   - Apply row-level security for multi-tenant data
   - Enable column-level encryption for PII
   - Use VPC Service Controls for additional network security

5. **Operational Excellence**
   - Monitor query performance with INFORMATION_SCHEMA views
   - Schedule routine maintenance jobs
   - Set up proper logging and monitoring
   - Implement data quality checks
   - Document data lineage

## Common Issues and Troubleshooting

### Performance Problems
- Check for missing partitioning or clustering
- Optimize JOIN operations (consider denormalizing)
- Review query plans for bottlenecks
- Use approximate aggregation functions for large datasets
- Consider materialized views for frequent queries

### Cost Issues
- Monitor with BigQuery audit logs
- Review largest queries by bytes processed
- Control who can run queries (IAM roles)
- Set user quotas to limit spending
- Optimize storage with appropriate compression

### Data Quality Problems
- Implement data validation queries
- Set up streaming inserts error handling
- Create data quality dashboards
- Use BigQuery Data Quality Services

### Access Control Issues
- Audit existing permissions with IAM Policy Analyzer
- Use groups instead of individual permissions
- Implement principle of least privilege
- Document access policies
- Regularly review and prune permissions

## Further Reading

- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [BigQuery Best Practices](https://cloud.google.com/bigquery/docs/best-practices-performance-overview)
- [BigQuery ML Documentation](https://cloud.google.com/bigquery-ml/docs)
- [Terraform BigQuery Resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset)
- [Data Warehouse Architecture Patterns](https://cloud.google.com/architecture/dw-patterns)