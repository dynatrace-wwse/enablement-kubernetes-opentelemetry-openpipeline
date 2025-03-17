## Wrap Up

### What You Learned Today 
By completing this lab, you've successfully deployed the OpenTelemetry Collector to collect metrics, traces, and logs from Kubernetes and ship them to Dynatrace for analysis.
- The Dynatrace Distro of OpenTelemetry Collector includes supported modules needed to ship telemetry to Dynatrace
    - The `otlp` receiver receives metrics, traces, and logs from OpenTelemetry exporters via gRPC/HTTP
    - The `filelog` receiver scrapes logs from the Node filesystem and parses the contents
    - The `prometheus` receiver scrapes metric data exposed by Pod Prometheus endpoints
- The Contrib Distro of OpenTelemetry Collector includes additional modules needed to ship telemetry to Dynatrace
    - The `kubeletstats` receiver scrapes metrics from the local kubelet on the Node
    - The `k8s_cluster` receiver queries the Kubernetes cluster API to retrieve metrics
    - The `k8sobjects` receiver watches for Kubernetes events (and other resources) on the cluster
- Dynatrace allows you to perform powerful queries and analysis of the telemetry data
- Observing the health of the OpenTelemetry Collectors and data pipeline is critical
    - The OpenTelemetry Collector exposes self-monitoring metrics in Prometheus format
