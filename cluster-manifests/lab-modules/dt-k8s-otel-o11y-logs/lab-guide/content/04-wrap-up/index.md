## Wrap Up

### What You Learned Today 
By completing this lab, you've successfully deployed the OpenTelemetry Collector to collect logs, enrich log attributes for better context, and ship those logs to Dynatrace for analysis.
- The OpenTelemetry Collector was deployed as a DaemonSet, behaving as an Agent running on each Node
- The Dynatrace Distro of OpenTelemetry Collector includes supported modules needed to ship logs to Dynatrace
    * The `filelog` receiver scrapes logs from the Node filesystem and parses the contents
    * The `otlp` receiver receives logs that are exported from agents, SDKs, and other Collectors
    * The `k8sattributes` processor enriches the logs with Kubernetes attributes
    * The `resourcedetection` processor enriches the logs with cloud and cluster attributes
    * The `resource` processor enriches the logs with custom (resource) attributes
- The Community Contrib Distro of OpenTelemetry Collector includes modules needed to ship events to Dynatrace
    * The `k8sobjects` receiver watches for Kubernetes events (and other resources) on the cluster
- Dynatrace DQL (via Notebooks) allows you to perform powerful queries and analysis of the log data