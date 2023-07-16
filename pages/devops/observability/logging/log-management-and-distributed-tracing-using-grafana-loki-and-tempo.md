# Log Management and Distributed Tracing using Grafana Loki and Tempo

With observability, collecting the measurements of logs, metrics, and distributed traces are the three key pillars to achieving success.

1. **Logs**: These are structured or unstructured text records of discreet events that occurred at a specific time.
2. **Metrics:** These are the values represented as counts or measures that are often calculated or aggregated over a period of time. Metrics can originate from a variety of sources, including infrastructure, hosts, services, cloud platforms, and external sources.
3. **Distributed tracing:** This displays activity of a transaction or request as it flows through applications and shows how services connect, including code-level details.

Logs and Distributed tracing are important aspect of any **Observability** platform. This blog explains instructions to setup Log management and distributed tracing using popular Open source observability platform Grafana and Grafana plugins Grafana LOKI and Grafana Tempo

Before we move into setup, let us look at the basics of Grafana, Grafana LOKI and Grafana Tempo

## Grafana <a href="#a70b" id="a70b"></a>

Grafana is a popular open-source interactive visualisation platform which allows users to see their data via charts and graphs that are unified into one dashboard for easier interpretation and understanding. We can also query and set alerts based on the metrics and thresholds. Grafana supports traditional server environments, Kubernetes Clusters and various Cloud Services. Being an open-source tool Grafana is Cloud Agnostics tool. When it comes to modern micro-services applications, Grafana integrates very well and can visualize deep level information of each micro-service.

## Grafana LOKI <a href="#b85d" id="b85d"></a>

Loki is a horizontally scalable, highly available, multi-tenant log aggregation solution. It’s designed to be both affordable and simple to use. Rather than indexing the contents of the logs, it uses a set of labels for each log stream.

Grafana Loki was inspired by Prometheus’ architecture, which uses labels to index data. This allows Loki to store indexes in less amount of space. Furthermore, Loki’s design is fully compatible with Prometheus, allowing developers to apply the same label criteria across the two platforms.

## Grafana Tempo <a href="#9437" id="9437"></a>

Grafana Tempo is an open source, easy-to-use, and high-scale distributed tracing backend. Tempo is cost-efficient, requiring only object storage to operate, and is deeply integrated with Grafana, Prometheus, and Loki. Tempo can ingest common open source tracing protocols, including Jaeger, Zipkin, and OpenTelemetry

## Grafana LOKI and Grafana Tempo Architecture <a href="#4aad" id="4aad"></a>

Below architecture explains how Grafana collects and monitor logs and tracing using Grafana LOKI and Grafana Tempo Extensions.

* For Logging, real time logs are collected using Fluent bit plugin deployed on each application servers and sent to centralized log management tool called **LOKI**. Then using Grafana LOKI data source in Grafana, these logs are visualized in Grafana Dashboard.
* For distributed tracing, Open Telemetry Collector receive, process and export telemetry data to to tracing backend Grafana Tempo. Then using Grafana Tempo data source in Grafana, these traces are visualized in Grafana Dashboard.
* Tempo and Loki both integrate with S3 buckets to store the data. This relieves you from maintaining and indexing storage that, depending on your requirements, might not be needed.
* Tempo and Loki are part of [Grafana](https://grafana.com/oss/). Therefore, it integrates seamlessly with Grafana dashboards.

## Setup Instructions <a href="#dfd8" id="dfd8"></a>

## Pre-requisites <a href="#a1f3" id="a1f3"></a>

This blog assumes that following components are already provisioned or installed.

* Kuberenetes Cluster
* Grafana Deployed on Kubernetes Cluster — Setup instructions can be found here [Deploy Grafana on Kubernetes | Grafana documentation](https://grafana.com/docs/grafana/latest/setup-grafana/installation/kubernetes/)
* Helm Charts installed on local system.

## Steps to setup Grafana LOKI and Grafana Tempo <a href="#b535" id="b535"></a>

1. Lets create the separate namespace for Grafana resources

```sh
kubectl create ns tracing
```

2\. Now we will use grafana helm chart to install Grafana Temp and Grafana LOKI. Initialise Grafana Helm chart repository and update the repository

```shell
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

3\. Deploy Grafana Tempo using helm chart

```sh
helm install tempo grafana/tempo --version 0.7.4 -n tracing -f - << 'EOF'
tempo:
 extraArgs:
   "distributor.log-received-traces": true
 receivers:
   zipkin:
   otlp:
     protocols:
       http:
       grpc:
EOF
```

\*\* — version will change in future please refer to the [link](https://github.com/grafana/helm-charts/tree/main/charts/tempo) to check the latest version.

4\. Deploy Grafana LOKI stack using helm charts.

```sh
helm install loki grafana/loki-stack --version 2.7.0 -n tracing -f - << 'EOF'
fluent-bit:
 enabled: false
promtail:
 enabled: true
prometheus:
 enabled: false
 alertmanager:
   persistentVolume:
     enabled: false
 server:
   persistentVolume:
     enabled: false
EOF
```

Above you can include and exclude the persistent volume, promtail, fluent-bit, Prometheus by making True or false.

\*\*if you are using LOKI, so promtail must have to enabled.

5\. Now, let’s deploy Open-telemetry Collector. You use this component to distribute the traces across your infrastructure:

```shell
kubectl apply -n tracing -f https://raw.githubusercontent.com/antonioberben/examples/master/opentelemetry-collector/otel.yaml
```

```yaml
kubectl apply -n tracing -f - << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
 name: otel-collector-conf
 labels:
   app: opentelemetry
   component: otel-collector-conf
data:
 otel-collector-config: |
   receivers:
     zipkin:
       endpoint: 0.0.0.0:9411
   exporters:
     otlp:
       endpoint: tempo.tracing.svc.cluster.local:55680
       insecure: true
   service:
     pipelines:
       traces:
         receivers: [zipkin]
         exporters: [otlp]
EOF
```

6\. Deploy fluent-bit component. You will use this component to scrap the log traces from your cluster:

(Note: In the configuration you are specifying to take only containers which match the following pattern `/var/log/containers/*.log`) in line number 16 of the below file

```sh
helm repo add fluent https://fluent.github.io/helm-charts

helm repo update
```

```sh
helm install fluent-bit fluent/fluent-bit --version 0.16.1 -n tracing -f - << 'EOF'
logLevel: trace
config:
 service: |
   [SERVICE]
       Flush 1
       Daemon Off
       Log_Level trace
       Parsers_File custom_parsers.conf
       HTTP_Server On
       HTTP_Listen 0.0.0.0
       HTTP_Port {{ .Values.service.port }}
 inputs: |
   [INPUT]
       Name tail
       Path /var/log/containers/*.log
       Parser cri
       Tag kube.*
       Mem_Buf_Limit 5MB
 outputs: |
   [OUTPUT]
       name loki
       match *
       host loki.tracing.svc
       port 3100
       tenant_id ""
       labels job=fluentbit
       label_keys $trace_id
       auto_kubernetes_labels on
 customParsers: |
   [PARSER]
       Name cri
       Format regex
       Regex ^(?<time>[^ ]+) (?<stream>stdout|stderr) (?<logtag>[^ ]*) (?<message>.*)$
       Time_Key    time
       Time_Format %Y-%m-%dT%H:%M:%S.%L%z
EOF
```

7\. This component is already configured to connect to Loki and Tempo:

```sh
helm install grafana grafana/grafana -n tracing --version 6.13.5  -f - << 'EOF'
datasources:
 datasources.yaml:
   apiVersion: 1
   datasources:
     - name: Tempo
       type: tempo
       access: browser
       orgId: 1
       uid: tempo
       url: http://tempo.tracing.svc:3100
       isDefault: true
       editable: true
     - name: Loki
       type: loki
       access: browser
       orgId: 1
       uid: loki
       url: http://loki.tracing.svc:3100
       isDefault: false
       editable: true
       jsonData:
         derivedFields:
           - datasourceName: Tempo
             matcherRegex: "traceID=(\\w+)"
             name: TraceID
             url: "$${__value.raw}"
             datasourceUid: tempo

env:
 JAEGER_AGENT_PORT: 6831

adminUser: admin
adminPassword: password

service:
 type: LoadBalancer

EOF
```

In the above Grafana Helm Chart we are defining the both Data Source of grafana with the help of datasource.yaml i.e. Tempo and Loki

we can also define the another data source in the Grafana in two ways:

a. In the Grafana UI we can go to the datasource and select the data source which we want to add and the url which we have to give is `http://<service_name>.<namespace>.svc:<service_port>`

b. Another option is to add new data source in the datasource.yaml, provide the configuration for the data source as shown in the above file, we can make any data source as default.

8\. Once everything is deployed lets see the status of each components in Kuberentes cluster

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*Nzi88oyCEOa5h5ow8EOQJQ.png" alt="" height="214" width="700"><figcaption></figcaption></figure>

In the above screenshot we can see that number of pod that are running in our cluster for Grafana and Tempo Setup. Here we are using Fluent-bit and promtail as a daemon set. We can see Pod for Grafana, Loki and Tempo also running

9\. Check the status of services deployed in kubernetes cluster

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*frjD3viSW8EETUdkWDkauw.png" alt="" height="154" width="700"><figcaption></figcaption></figure>

In the above screenshot, we can see that number of services are created for resources that we had deployed for Setting the Grafana, Loki and Tempo.

10\. Now we will login to Grafana UI with the service url that provided in above screenshot, with the username and password are provided when we are executing the helm chart of the Grafana

11\. Click on Explore, You will there are two data source **LOKI** and **Tempo** and in the Grafana datasource.yaml we had defined the **Tempo** as default data source.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*q0aI7BA7xxphWL5fA0Qezg.png" alt="" height="208" width="700"><figcaption></figcaption></figure>

12\. Select **LOKI** as the current data source. You will see the interface like below mentioned.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*mH0uVJjsQMqgB9n-wockzQ.png" alt="" height="203" width="700"><figcaption></figcaption></figure>

13\. Click on the **log browser button,** you will the different labels as shown below.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*Ta9ULZEVI1AfgWJ-DT--7g.png" alt="" height="303" width="700"><figcaption></figcaption></figure>

Here **LOKI** provide the log filtration on the basis of labels, you can we have different labels like pod, namespace, node\_name, release, app, containers, etc .

14\. Now what we will do here is let take example of Grafana pod and we will see the logs of Grafana Pod.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*s0rwc3uexkQogSP7UIkeDg.png" alt="" height="379" width="700"><figcaption></figcaption></figure>

Here we are selecting label as a pod and in the pod section we can see we have 24 Pod, we can filter out on basis of labels as well. example: filtering on the basis of namespace or container or node or app. When we select our Grafana Pod, In the 3rd step Loki will show the result of our query and after clicking on the button of **Show logs** you will able to see the logs in the Grafana.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*iOCmXqvhCIR4sva7uQSeOQ.png" alt="" height="420" width="700"><figcaption></figcaption></figure>

15\. Expand any log trace, you can see the detailed logs of Grafana Pod and you will also notice **TraceID** field is detected in the logs. Once you expand the logs you will also notice Tempo button in front of **TraceID** field

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*PBYIlFuUi7DBqLIpX7V7WA.png" alt="" height="390" width="700"><figcaption></figcaption></figure>

16\. You can see the Services and the Operation of the Trace ID we had provided into the **Tempo**.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*xtAikCSKe2ILf-TDS3GLjQ.png" alt="" height="406" width="700"><figcaption></figcaption></figure>

17\. In the New version of Tempo (currently in beta ), there is a node graph where we can see the connected hub from where our Traces passed.

<figure><img src="https://miro.medium.com/v2/resize:fit:700/1*o0Q18Q2WCTPPVfYmMRkORQ.png" alt="" height="380" width="700"><figcaption></figcaption></figure>

As we can see above how we can see the logs and distributed tracing using Grafana LOKI and Temp.
