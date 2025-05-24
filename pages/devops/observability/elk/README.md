# ElasticSearch, Logstash, and Kibana (ELK/Opensearch): Enterprise Observability

## Introduction & History

The ELK stack—ElasticSearch, Logstash, and Kibana—has been a cornerstone of log analytics and observability for over a decade. Originally developed by Elastic, it is widely used for centralized logging, search, and visualization. Opensearch, a community-driven fork, is also popular in cloud-native and open-source environments.

- **ElasticSearch**: Distributed search and analytics engine for logs, metrics, and more
- **Logstash**: Data processing pipeline for ingesting, transforming, and forwarding logs
- **Kibana**: Visualization and dashboarding for ElasticSearch data
- **Opensearch**: AWS-led fork of ElasticSearch and Kibana, fully open-source

## Why Use ELK/Opensearch?

- Powerful full-text search and analytics
- Scales to petabytes of data
- Flexible data ingestion and transformation
- Rich visualization and alerting
- Supported by all major clouds (AWS, Azure, GCP)

---

## ElasticSearch: Search & Analytics Engine

### Installation (Docker Example)

```bash
docker network create elk

docker run -d --name elasticsearch --net elk \
  -e "discovery.type=single-node" \
  -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" \
  -p 9200:9200 -p 9300:9300 \
  docker.elastic.co/elasticsearch/elasticsearch:8.11.3
```

### Cloud Integrations

- **AWS**: Use [Amazon OpenSearch Service](https://aws.amazon.com/opensearch-service/) (managed) or self-hosted
- **Azure**: Use [Azure Marketplace Elastic offering](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/elastic.elasticsearch) or self-hosted
- **GCP**: Use [Elastic Cloud on GCP](https://cloud.google.com/marketplace/product/elastic-cloud/elastic-cloud-enterprise) or self-hosted

---

## Logstash: Data Ingestion & Processing

### Installation (Docker Example)

```bash
docker run -d --name logstash --net elk \
  -e "LS_JAVA_OPTS=-Xms512m -Xmx512m" \
  -v $(pwd)/logstash.conf:/usr/share/logstash/pipeline/logstash.conf \
  docker.elastic.co/logstash/logstash:8.11.3
```

### Example: Logstash Pipeline for Syslog

```conf
input {
  tcp { port => 5000 type => syslog }
}
filter {
  grok { match => { "message" => "%{SYSLOGLINE}" } }
}
output {
  elasticsearch { hosts => ["elasticsearch:9200"] }
}
```

---

## Kibana: Visualization & Dashboards

### Installation (Docker Example)

```bash
docker run -d --name kibana --net elk \
  -e "ELASTICSEARCH_HOSTS=http://elasticsearch:9200" \
  -p 5601:5601 \
  docker.elastic.co/kibana/kibana:8.11.3
```

### Cloud Integrations

- **AWS**: Use [Amazon OpenSearch Dashboards](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/dashboards.html)
- **Azure**: Use Elastic on Azure or self-hosted
- **GCP**: Use Elastic Cloud or self-hosted

---

## Tips & Tricks for Linux, WSL, and NixOS

- **Linux**: Use systemd for service management. Install via package manager, Docker, or official tarballs.
- **WSL**: Use Docker Desktop or WSL2 for running containers. Expose ports for Kibana UI access.
- **NixOS**: Use [nixpkgs](https://search.nixos.org/packages) for reproducible installs:

  ```nix
  environment.systemPackages = with pkgs; [ elasticsearch logstash kibana ];
  ```

- Always use environment variables or config files for credentials—never hard-code secrets.
- For persistent storage, mount volumes for ElasticSearch data directories.

---

## Pros & Cons vs. Grafana/Loki/Prometheus

| Feature         | ELK/Opensearch                  | Grafana/Loki/Prometheus         |
|-----------------|---------------------------------|---------------------------------|
| Cost            | Can be resource-intensive, license cost | Open-source, low resource usage |
| Metrics         | Not native, needs Beats/Metricbeat   | Native (Prometheus)             |
| Logs            | Logstash/Beats, powerful search      | Loki (log-native, efficient)    |
| Visualization   | Kibana (powerful, but ES-centric)    | Grafana (flexible, modern)      |
| Cloud Support   | Good, but often tied to vendor       | Excellent, cloud-agnostic       |
| Scaling         | Scales well, but complex to manage   | Easy for most use cases         |
| Alerting        | X-Pack, Watcher (paid in ES)         | Prometheus Alertmanager, Grafana|

**Best Practice:** Use ELK/Opensearch for heavy log analytics, full-text search, and compliance use cases. Use Grafana stack for cloud-native/Kubernetes and metrics-driven monitoring.

---

## References

- [ElasticSearch Docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Logstash Docs](https://www.elastic.co/guide/en/logstash/current/index.html)
- [Kibana Docs](https://www.elastic.co/guide/en/kibana/current/index.html)
- [Opensearch Docs](https://opensearch.org/docs/)
- [Amazon OpenSearch Service](https://aws.amazon.com/opensearch-service/)
