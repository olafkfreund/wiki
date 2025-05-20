# JQ

`jq` is a lightweight and flexible command-line tool for processing and manipulating JSON data. It is essential for DevOps engineers working with APIs, cloud CLIs, and automation scripts, as it allows you to extract, filter, and transform JSON data efficiently.

## Installation

**Linux (Debian/Ubuntu):**

```sh
sudo apt-get update && sudo apt-get install jq
```

**macOS (Homebrew):**

```sh
brew install jq
```

**Windows (WSL):**

```sh
sudo apt-get update && sudo apt-get install jq
```

See the [official jq installation guide](https://stedolan.github.io/jq/download/) for more options.

## Common Use Cases

### 1. Extracting Data

Extract specific fields from a JSON array. For example, to get all employee names:

```sh
cat employees.json | jq '.[].name'
```

### 2. Filtering Data

Filter objects based on conditions. For example, list products with a price less than $10:

```sh
cat products.json | jq '.[] | select(.price < 10)'
```

### 3. Transforming Data (to CSV)

Convert JSON to CSV for reporting or further processing:

```sh
cat orders.json | jq -r '["OrderID","CustomerID","OrderDate"], (.[] | [.OrderID,.CustomerID,.OrderDate]) | @csv'
```

## Real-World DevOps Examples

### Azure CLI + jq

Extract VM names from Azure:

```sh
az vm list --output json | jq -r '.[].name'
```

### AWS CLI + jq

List all EC2 instance IDs:

```sh
aws ec2 describe-instances | jq -r '.Reservations[].Instances[].InstanceId'
```

### Kubernetes + jq

Get all pod names in a namespace:

```sh
kubectl get pods -n my-namespace -o json | jq -r '.items[].metadata.name'
```

## Best Practices

- Always use `-r` (raw output) when you need plain text instead of JSON strings.
- Use `jq` in pipelines to automate cloud resource management and reporting.
- Validate your jq filters with sample data before using in production scripts.

## References

- [jq Manual](https://stedolan.github.io/jq/manual/)
- [jq Cookbook](https://github.com/stedolan/jq/wiki/Cookbook)

---

> **Tip:** Combine jq with tools like `xargs`, `awk`, or `sed` for even more powerful automation workflows.
