## OpenTelemetry Metrics

### What You’ll Learn Today
In this lab we'll utilize the OpenTelemetry Collector deployed as a DaemonSet (Node Agent) to collect Node (kubelet) metrics from a Kubernetes cluster and ship them to Dynatrace.  Additionally, we'll utilize a second OpenTelemetry Collector deployed as a Deployment (Gateway) to collect Cluster (Kubernetes API) metrics from the Kubernetes cluster and ship them to Dynatrace.

Lab tasks:
1. Deploy OpenTelemetry Collector as a DaemonSet
2. Configure OpenTelemetry Collector service pipeline for metric enrichment
3. Deploy OpenTelemetry Collector as a Deployment
4. Configure OpenTelemetry Collector service pipeline for metric enrichment
5. Query and visualize metrics in Dynatrace using DQL