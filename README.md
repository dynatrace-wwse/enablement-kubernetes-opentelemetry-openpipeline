id: enablement-kubernetes-opentelemetry-openpipeline\
summary: opentelemetry log processing with dynatrace openpipeline\
author: Tony Pope-Cruz

# Enablement Kubernetes OpenTelemetry OpenPipeline

During this hands-on training, we’ll learn how to capture logs from Kubernetes using OpenTelemetry and ship them to Dynatrace for analysis.  This will demonstrate how to use Dynatrace with OpenTelemetry; without any Dynatrace native components installed on the Kubernetes cluster (Operator, OneAgent, ActiveGate, etc.).  We'll then utilize Dynatrace OpenPipeline to process OpenTelemetry logs at ingest, in order to make them easier to analyze and leverage.  The OpenTelemetry Collector logs are output mixed JSON/console format, making them difficult to use by default.  With OpenPipeline, the logs will be processed at ingest, to manipulate fields, extract metrics, and raise alert events in case of any issues.

Lab tasks:
1. Ingest Kubernetes logs using OpenTelemetry Collector
1. Deploy OpenTelemetry Collector for logs, traces, and metrics
1. Parse OpenTelemetry Collector logs using DQL in a Notebook, giving you flexibility at query time
1. Parse OpenTelemetry Collector logs at ingest using Dynatrace OpenPipeline, giving you simplicity at query time
1. Query and visualize logs and metrics in Dynatrace using DQL

Ready to learn how to ship Kubernetes logs with OpenTelemetry and process them with Dynatrace OpenPipeline?

## [View the Lab Guide](https://dynatrace-wwse.github.io/enablement-kubernetes-opentelemetry-openpipeline)