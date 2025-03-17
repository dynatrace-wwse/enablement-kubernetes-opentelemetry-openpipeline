## Wrap Up

### What You Learned Today 
By completing this lab, you've successfully deployed the OpenTelemetry Collector to collect traces, enrich span attributes for better context, and ship those traces/spans to Dynatrace for analysis.
- The OpenTelemetry Collector was deployed as a Deployment, behaving as a Gateway on the cluster
- The Dynatrace Distro of OpenTelemetry Collector includes supported modules needed to ship traces to Dynatrace
    * The `otlp` receiver receives traces (and other signals) from OpenTelemetry exporters via gRPC/HTTP
    * The `k8sattributes` processor enriches the spans with Kubernetes attributes
    * The `resourcedetection` processor enriches the spans with cloud and cluster (GCP/GKE) attributes
    * The `resource` processor enriches the spans with custom (resource) attributes
- Dynatrace allows you to perform powerful queries and analysis of the trace/span data