# Grafana, Loki, and Prometheus: Cloud-Native Observability

## Introduction & History

Grafana, Loki, and Prometheus are open-source tools that form a powerful observability stack for monitoring, logging, and alerting in cloud-native environments. Originally developed by different teams (Prometheus by SoundCloud, Grafana by Torkel Ödegaard, Loki by Grafana Labs), they are now widely adopted in DevOps and SRE workflows across AWS, Azure, and GCP.

- **Prometheus**: Time-series metrics collection and alerting (CNCF project)
- **Grafana**: Visualization and dashboarding for metrics, logs, and traces
- **Loki**: Log aggregation, designed to work seamlessly with Grafana

## Why Use This Stack?

- Cloud-agnostic: Works on AWS, Azure, GCP, and on-prem
- Open-source, extensible, and widely supported
- Integrates with Kubernetes, Docker, and major cloud services

---

## Prometheus: Metrics Collection & Alerting

### Installation (Kubernetes Example)

```bash
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus \
  --namespace monitoring
```

### Cloud Integrations

- **AWS**: Use [YACE](https://github.com/yace-io/yace) or CloudWatch exporter for AWS metrics
- **Azure**: Use [Azure Monitor exporter](https://github.com/RobustPerception/azure_metrics_exporter)
- **GCP**: Use [Stackdriver exporter](https://github.com/frodenas/stackdriver_exporter)

### Example: Scraping EC2 Metrics (AWS)

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'aws_ec2'
    static_configs:
      - targets: ['yace-exporter:5000']
```

---

## Loki: Log Aggregation

### Installation (Kubernetes Example)

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install loki grafana/loki-stack \
  --namespace monitoring
```

### Cloud Integrations

- **AWS**: Use CloudWatch Logs agent to ship logs to Loki or use [Promtail](https://grafana.com/docs/loki/latest/clients/promtail/)
- **Azure**: Use [Azure Monitor exporter](https://github.com/grafana/loki/tree/main/clients/cmd/azurelog)
- **GCP**: Use [Google Cloud Logging exporter](https://github.com/grafana/loki/tree/main/clients/cmd/gcplog)

### Example: Promtail Config for Kubernetes

```yaml
server:
  http_listen_port: 9080
positions:
  filename: /tmp/positions.yaml
clients:
  - url: http://loki:3100/loki/api/v1/push
scrape_configs:
  - job_name: kubernetes-pods
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        target_label: app
```

---

## Grafana: Visualization & Dashboards

### Installation (Kubernetes Example)

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana \
  --namespace monitoring \
  --set adminPassword='YourPassword'
```

### Cloud Integrations

- **AWS**: Use [Amazon Managed Grafana](https://aws.amazon.com/grafana/) or self-hosted
- **Azure**: Use [Azure Managed Grafana](https://learn.microsoft.com/en-us/azure/managed-grafana/)
- **GCP**: Deploy on GKE or use [Grafana Cloud](https://grafana.com/products/cloud/)

### Example: Adding Prometheus & Loki as Data Sources

1. Log in to Grafana UI
2. Go to **Configuration > Data Sources**
3. Add Prometheus (URL: `http://prometheus:9090`)
4. Add Loki (URL: `http://loki:3100`)

---

## Tips & Tricks for Linux, WSL, and NixOS

- **Linux**: Use systemd for service management. Install via package manager or Docker for easy upgrades.
- **WSL**: Use Docker Desktop or WSL2 for running containers. Expose ports for Grafana UI access.
- **NixOS**: Use [nixpkgs](https://search.nixos.org/packages) for reproducible installs:

  ```nix
  environment.systemPackages = with pkgs; [ grafana prometheus loki ];
  ```

- Always use environment variables or config files for credentials—never hard-code secrets.
- For persistent storage, mount volumes for Prometheus and Loki data directories.

---

## Pros & Cons vs. ElasticSearch (ELK/Opensearch)

| Feature         | Grafana/Loki/Prometheus         | ElasticSearch/ELK/Opensearch         |
|-----------------|---------------------------------|--------------------------------------|
| Cost            | Open-source, low resource usage | Can be resource-intensive, license cost|
| Metrics         | Native (Prometheus)             | Not native, needs Beats/Metricbeat   |
| Logs            | Loki (log-native, efficient)    | Logstash/Beats, powerful search      |
| Visualization   | Grafana (flexible, modern)      | Kibana (powerful, but ES-centric)    |
| Cloud Support   | Excellent, cloud-agnostic       | Good, but often tied to vendor       |
| Scaling         | Easy for most use cases         | Scales well, but complex to manage   |
| Alerting        | Prometheus Alertmanager, Grafana| X-Pack, Watcher (paid in ES)         |

**Best Practice:** Use Grafana stack for cloud-native/Kubernetes, and ELK/Opensearch for heavy log analytics or when deep search is required.

---

## References

- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)
- [Loki Docs](https://grafana.com/docs/loki/latest/)
- [ELK Stack Docs](https://www.elastic.co/what-is/elk-stack)
- [Opensearch Docs](https://opensearch.org/docs/)
