# Terraform

Create a file named `auth.tf`, and add the following content to the file. This configuration initializes the Databricks Terraform provider and authenticates Terraform with your workspace.

To authenticate with a Databricks CLI configuration profile, add the following content:

```hcl
variable "databricks_connection_profile" {
  description = "The name of the Databricks connection profile to use."
  type        = string
}

# Initialize the Databricks Terraform provider.
terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

# Use Databricks CLI authentication.
provider "databricks" {
  profile = var.databricks_connection_profile
}

# Retrieve information about the current user.
data "databricks_current_user" "me" {}
```plaintext

To authenticate with environment variables, add the following content instead.&#x20;

```hcl
# Initialize the Databricks Terraform provider.
terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

# Use environment variables for authentication.
provider "databricks" {}

# Retrieve information about the current user.
data "databricks_current_user" "me" {}
```plaintext

To authenticate with the Azure CLI, add the following content instead:

```hcl
variable "databricks_host" {
  description = "The Azure Databricks workspace URL."
  type        = string
}

# Initialize the Databricks Terraform provider.
terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

# Use Azure CLI authentication.
provider "databricks" {
  host = var.databricks_host
}

# Retrieve information about the current user.
data "databricks_current_user" "me" {}
```plaintext

Create another file named `auth.auto.tfvars`, and add the following content to the file. This file contains variable values for authenticating Terraform with your workspace. Replace the placeholder values with your own values.

To authenticate with a Databricks CLI configuration profile, add the following content:

Copy

```hcl
databricks_connection_profile = "DEFAULT"
```plaintext

To authenticate with the Azure CLI, add the following content instead:

Copy

```hcl
databricks_host = "https://<workspace-instance-name>"
```plaintext

To authenticate with with environment variables, you do not need an `auth.auto.tfvars` file.

```bash
terraform init
```plaintext

Create another file named `cluster.tf`, and add the following content to the file. This content creates a cluster with the smallest amount of resources allowed. This cluster uses the lastest Databricks Runtime Long Term Support (LTS) version.

For a cluster that works with Unity Catalog:

```hcl
variable "cluster_name" {}
variable "cluster_autotermination_minutes" {}
variable "cluster_num_workers" {}
variable "cluster_data_security_mode" {}

# Create the cluster with the "smallest" amount
# of resources allowed.
data "databricks_node_type" "smallest" {
  local_disk = true
}

# Use the latest Databricks Runtime
# Long Term Support (LTS) version.
data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

resource "databricks_cluster" "this" {
  cluster_name            = var.cluster_name
  node_type_id            = data.databricks_node_type.smallest.id
  spark_version           = data.databricks_spark_version.latest_lts.id
  autotermination_minutes = var.cluster_autotermination_minutes
  num_workers             = var.cluster_num_workers
  data_security_mode      = var.cluster_data_security_mode
}

output "cluster_url" {
 value = databricks_cluster.this.url
}
```plaintext

For an all-purpose cluster:

```hcl
variable "cluster_name" {
  description = "A name for the cluster."
  type        = string
  default     = "My Cluster"
}

variable "cluster_autotermination_minutes" {
  description = "How many minutes before automatically terminating due to inactivity."
  type        = number
  default     = 60
}

variable "cluster_num_workers" {
  description = "The number of workers."
  type        = number
  default     = 1
}

# Create the cluster with the "smallest" amount
# of resources allowed.
data "databricks_node_type" "smallest" {
  local_disk = true
}

# Use the latest Databricks Runtime
# Long Term Support (LTS) version.
data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

resource "databricks_cluster" "this" {
  cluster_name            = var.cluster_name
  node_type_id            = data.databricks_node_type.smallest.id
  spark_version           = data.databricks_spark_version.latest_lts.id
  autotermination_minutes = var.cluster_autotermination_minutes
  num_workers             = var.cluster_num_workers
}

output "cluster_url" {
 value = databricks_cluster.this.url
}
```plaintext

Create another file named `cluster.auto.tfvars`, and add the following content to the file. This file contains variable values for customizing the cluster. Replace the placeholder values with your own values.

For a cluster that works with Unity Catalog:

```hcl
cluster_name                    = "My Cluster"
cluster_autotermination_minutes = 60
cluster_num_workers             = 1
cluster_data_security_mode      = "SINGLE_USER"
```plaintext

For an all-purpose cluster:

```hcl
cluster_name                    = "My Cluster"
cluster_autotermination_minutes = 60
cluster_num_workers             = 1
```plaintext

Create another file named `notebook.tf`, and add the following content to the file:

```hcl
variable "notebook_subdirectory" {
  description = "A name for the subdirectory to store the notebook."
  type        = string
  default     = "Terraform"
}

variable "notebook_filename" {
  description = "The notebook's filename."
  type        = string
}

variable "notebook_language" {
  description = "The language of the notebook."
  type        = string
}

resource "databricks_notebook" "this" {
  path     = "${data.databricks_current_user.me.home}/${var.notebook_subdirectory}/${var.notebook_filename}"
  language = var.notebook_language
  source   = "./${var.notebook_filename}"
}

output "notebook_url" {
 value = databricks_notebook.this.url
}
```plaintext

\
For the Python notebook a file named `notebook-getting-started-lakehouse-e2e.py` with the following contents:

```python
# Databricks notebook source
external_location = "<your_external_location>"
catalog = "<your_catalog>"

dbutils.fs.put(f"{external_location}/foobar.txt", "Hello world!", True)
display(dbutils.fs.head(f"{external_location}/foobar.txt"))
dbutils.fs.rm(f"{external_location}/foobar.txt")

display(spark.sql(f"SHOW SCHEMAS IN {catalog}"))

# COMMAND ----------

from pyspark.sql.functions import col

# Set parameters for isolation in workspace and reset demo
username = spark.sql("SELECT regexp_replace(current_user(), '[^a-zA-Z0-9]', '_')").first()[0]
database = f"{catalog}.e2e_lakehouse_{username}_db"
source = f"{external_location}/e2e-lakehouse-source"
table = f"{database}.target_table"
checkpoint_path = f"{external_location}/_checkpoint/e2e-lakehouse-demo"

spark.sql(f"SET c.username='{username}'")
spark.sql(f"SET c.database={database}")
spark.sql(f"SET c.source='{source}'")

spark.sql("DROP DATABASE IF EXISTS ${c.database} CASCADE")
spark.sql("CREATE DATABASE ${c.database}")
spark.sql("USE ${c.database}")

# Clear out data from previous demo execution
dbutils.fs.rm(source, True)
dbutils.fs.rm(checkpoint_path, True)

# Define a class to load batches of data to source
class LoadData:

  def __init__(self, source):
    self.source = source

  def get_date(self):
    try:
      df = spark.read.format("json").load(source)
    except:
        return "2016-01-01"
    batch_date = df.selectExpr("max(distinct(date(tpep_pickup_datetime))) + 1 day").first()[0]
    if batch_date.month == 3:
      raise Exception("Source data exhausted")
      return batch_date

  def get_batch(self, batch_date):
    return (
      spark.table("samples.nyctaxi.trips")
        .filter(col("tpep_pickup_datetime").cast("date") == batch_date)
    )

  def write_batch(self, batch):
    batch.write.format("json").mode("append").save(self.source)

  def land_batch(self):
    batch_date = self.get_date()
    batch = self.get_batch(batch_date)
    self.write_batch(batch)

RawData = LoadData(source)

# COMMAND ----------

RawData.land_batch()

# COMMAND ----------

# Import functions
from pyspark.sql.functions import input_file_name, current_timestamp

# Configure Auto Loader to ingest JSON data to a Delta table
(spark.readStream
  .format("cloudFiles")
  .option("cloudFiles.format", "json")
  .option("cloudFiles.schemaLocation", checkpoint_path)
  .load(file_path)
  .select("*", input_file_name().alias("source_file"), current_timestamp().alias("processing_time"))
  .writeStream
  .option("checkpointLocation", checkpoint_path)
  .trigger(availableNow=True)
  .option("mergeSchema", "true")
  .toTable(table))

# COMMAND ----------

df = spark.read.table(table_name)

# COMMAND ----------

display(df)
```plaintext

For the Python notebook  a file named `notebook-quickstart-create-databricks-workspace-portal.py` with the following contents:

```python
# Databricks notebook source
blob_account_name = "azureopendatastorage"
blob_container_name = "citydatacontainer"
blob_relative_path = "Safety/Release/city=Seattle"
blob_sas_token = r""

# COMMAND ----------

wasbs_path = 'wasbs://%s@%s.blob.core.windows.net/%s' % (blob_container_name, blob_account_name,blob_relative_path)
spark.conf.set('fs.azure.sas.%s.%s.blob.core.windows.net' % (blob_container_name, blob_account_name), blob_sas_token)
print('Remote blob path: ' + wasbs_path)

# COMMAND ----------

df = spark.read.parquet(wasbs_path)
print('Register the DataFrame as a SQL temporary view: source')
df.createOrReplaceTempView('source')

# COMMAND ----------

print('Displaying top 10 rows: ')
display(spark.sql('SELECT * FROM source LIMIT 10'))
```plaintext

If you are creating the notebook, create another file named `notebook.auto.tfvars`, and add the following content to the file. This file contains variable values for customizing the notebook configuration.

For the Python notebook:

```hcl
notebook_subdirectory = "Terraform"
notebook_filename     = "notebook-getting-started-lakehouse-e2e.py"
notebook_language     = "PYTHON"
```plaintext

For the Python notebook:

```hcl
notebook_subdirectory = "Terraform"
notebook_filename     = "notebook-quickstart-create-databricks-workspace-portal.py"
notebook_language     = "PYTHON"
```plaintext

If you are creating a notebook, in your Azure Databricks workspace, be sure to set up any requirements for the notebook to run successfully.



If you are creating a job, create another file named `job.tf`, and add the following content to the file. This content creates a job to run the notebook.

```hcl
variable "job_name" {
  description = "A name for the job."
  type        = string
  default     = "My Job"
}

resource "databricks_job" "this" {
  name = var.job_name
  existing_cluster_id = databricks_cluster.this.cluster_id
  notebook_task {
    notebook_path = databricks_notebook.this.path
  }
  email_notifications {
    on_success = [ data.databricks_current_user.me.user_name ]
    on_failure = [ data.databricks_current_user.me.user_name ]
  }
}

output "job_url" {
  value = databricks_job.this.url
}
```plaintext

If you are creating the job, create another file named `job.auto.tfvars`, and add the following content to the file. This file contains a variable value for customizing the job configuration.

Copy

```hcl
job_name = "My Job"
```plaintext



```plaintext
terraform validate
```plaintext

```plaintext
terraform plan
```plaintext

```plaintext
terraform apply
```plaintext

\


\


