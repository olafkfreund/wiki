# Manage Databricks workspaces

The following configuration blocks initialize the most common variables, [databricks\_spark\_version](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/spark\_version), [databricks\_node\_type](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/node\_type), and [databricks\_current\_user](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/current\_user).

```hcl
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
    }
  }
}

provider "databricks" {}

data "databricks_current_user" "me" {}
data "databricks_spark_version" "latest" {}
data "databricks_node_type" "smallest" {
  local_disk = true
}
```plaintext

### Standard functionality <a href="#standard-functionality" id="standard-functionality"></a>

These resources do not require administrative privileges. More documentation is available at the dedicated pages [databricks\_secret\_scope](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret\_scope), [databricks\_token](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/token), [databricks\_secret](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret), [databricks\_notebook](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/notebook), [databricks\_job](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/job), [databricks\_cluster](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster), [databricks\_cluster\_policy](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster\_policy), [databricks\_instance\_pool](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/instance\_pool).

```hcl
resource "databricks_secret_scope" "this" {
  name = "demo-${data.databricks_current_user.me.alphanumeric}"
}

resource "databricks_token" "pat" {
  comment          = "Created from ${abspath(path.module)}"
  lifetime_seconds = 3600
}

resource "databricks_secret" "token" {
  string_value = databricks_token.pat.token_value
  scope        = databricks_secret_scope.this.name
  key          = "token"
}

resource "databricks_notebook" "this" {
  path     = "${data.databricks_current_user.me.home}/Terraform"
  language = "PYTHON"
  content_base64 = base64encode(<<-EOT
    token = dbutils.secrets.get('${databricks_secret_scope.this.name}', '${databricks_secret.token.key}')
    print(f'This should be redacted: {token}')
    EOT
  )
}

resource "databricks_job" "this" {
  name = "Terraform Demo (${data.databricks_current_user.me.alphanumeric})"
  new_cluster {
    num_workers   = 1
    spark_version = data.databricks_spark_version.latest.id
    node_type_id  = data.databricks_node_type.smallest.id
  }

  notebook_task {
    notebook_path = databricks_notebook.this.path
  }

  email_notifications {}
}

resource "databricks_cluster" "this" {
  cluster_name = "Exploration (${data.databricks_current_user.me.alphanumeric})"
  spark_version           = data.databricks_spark_version.latest.id
  instance_pool_id        = databricks_instance_pool.smallest_nodes.id
  autotermination_minutes = 20
  autoscale {
    min_workers = 1
    max_workers = 10
  }
}

resource "databricks_cluster_policy" "this" {
  name = "Minimal (${data.databricks_current_user.me.alphanumeric})"
  definition = jsonencode({
    "dbus_per_hour" : {
      "type" : "range",
      "maxValue" : 10
    },
    "autotermination_minutes" : {
      "type" : "fixed",
      "value" : 20,
      "hidden" : true
    }
  })
}

resource "databricks_instance_pool" "smallest_nodes" {
  instance_pool_name = "Smallest Nodes (${data.databricks_current_user.me.alphanumeric})"
  min_idle_instances = 0
  max_capacity       = 30
  node_type_id       = data.databricks_node_type.smallest.id
  preloaded_spark_versions = [
    data.databricks_spark_version.latest.id
  ]

  idle_instance_autotermination_minutes = 20
}

output "notebook_url" {
  value = databricks_notebook.this.url
}

output "job_url" {
  value = databricks_job.this.url
}
```plaintext

### Workspace security <a href="#workspace-security" id="workspace-security"></a>

Managing security requires administrative privileges. More documentation is available at the dedicated pages [databricks\_secret\_acl](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret\_acl), [databricks\_group](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/group), [databricks\_user](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/user), [databricks\_group\_member](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group\_member), [databricks\_permissions](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions).

```hcl
resource "databricks_secret_acl" "spectators" {
  principal  = databricks_group.spectators.display_name
  scope      = databricks_secret_scope.this.name
  permission = "READ"
}

resource "databricks_group" "spectators" {
  display_name = "Spectators (by ${data.databricks_current_user.me.alphanumeric})"
}

resource "databricks_user" "dummy" {
  user_name    = "dummy+${data.databricks_current_user.me.alphanumeric}@example.com"
  display_name = "Dummy ${data.databricks_current_user.me.alphanumeric}"
}

resource "databricks_group_member" "a" {
  group_id  = databricks_group.spectators.id
  member_id = databricks_user.dummy.id
}

resource "databricks_permissions" "notebook" {
  notebook_path = databricks_notebook.this.id
  access_control {
    user_name        = databricks_user.dummy.user_name
    permission_level = "CAN_RUN"
  }
  access_control {
    group_name       = databricks_group.spectators.display_name
    permission_level = "CAN_READ"
  }
}

resource "databricks_permissions" "job" {
  job_id = databricks_job.this.id
  access_control {
    user_name        = databricks_user.dummy.user_name
    permission_level = "IS_OWNER"
  }
  access_control {
    group_name       = databricks_group.spectators.display_name
    permission_level = "CAN_MANAGE_RUN"
  }
}

resource "databricks_permissions" "cluster" {
  cluster_id = databricks_cluster.this.id
  access_control {
    user_name        = databricks_user.dummy.user_name
    permission_level = "CAN_RESTART"
  }
  access_control {
    group_name       = databricks_group.spectators.display_name
    permission_level = "CAN_ATTACH_TO"
  }
}

resource "databricks_permissions" "policy" {
  cluster_policy_id = databricks_cluster_policy.this.id
  access_control {
    group_name       = databricks_group.spectators.display_name
    permission_level = "CAN_USE"
  }
}

resource "databricks_permissions" "pool" {
  instance_pool_id = databricks_instance_pool.smallest_nodes.id
  access_control {
    group_name       = databricks_group.spectators.display_name
    permission_level = "CAN_ATTACH_TO"
  }
}
```plaintext

### Advanced configuration <a href="#advanced-configuration" id="advanced-configuration"></a>

```hcl
data "http" "my" {
  url = "https://ifconfig.me"
}

resource "databricks_workspace_conf" "this" {
  custom_config = {
    "enableIpAccessLists": "true"
  }
}

resource "databricks_ip_access_list" "only_me" {
  label = "only ${data.http.my.body} is allowed to access workspace"
  list_type = "ALLOW"
  ip_addresses = ["${data.http.my.body}/32"]
  depends_on = [databricks_workspace_conf.this]
}
```plaintext
