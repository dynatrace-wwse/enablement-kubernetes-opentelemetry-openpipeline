## Wrap Up

### What You Learned Today 
By completing this lab, you've successfully deployed the OpenTelemetry Collector to collect metrics, enrich metric attributes for better context, and ship those metrics to Dynatrace for analysis.
- One Community Contrib Distro OpenTelemetry Collector was deployed as a DaemonSet, behaving as an Agent running on each Node
    * The `kubeletstats` receiver scrapes metrics from the local kubelet on the Node
    * The `k8sattributes` processor enriches the metrics with Kubernetes attributes that may be missing without it
- A second Community Contrib Distro OpenTelemetry Collector was deployed as a Deployment, behaving as a Gateway
    * The `k8s_cluster` receiver queries the Kubernetes cluster API to retrieve metrics
    * The `k8sattributes` processor enriches the metrics with Kubernetes attributes that may be missing without it
    * The `otlp` receiver receives signals that are exported from agents, SDKs, and other Collectors
- Metrics produced by the OpenTelemetry SDKs and Agents are exported to the `otlp` receiver
- Dynatrace DQL (via Notebooks) allows you to perform powerful queries and analysis of the metric data