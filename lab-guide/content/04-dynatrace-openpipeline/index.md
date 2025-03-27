## Dynatrace OpenPipeline
In this lab we'll utilize Dynatrace OpenPipeline to process OpenTelemetry logs at ingest, in order to make them easier to analyze and leverage.  The logs will be ingested by OpenTelemetry Collector, deployed on Kubernetes as part of the previous lab.  The OpenTelemetry Collector logs are output mixed JSON/console format, making them difficult to use by default.  With OpenPipeline, the logs will be processed at ingest, to manipulate fields, extract metrics, and raise alert events in case of any issues.

![OpenPipeline](../../assets/images/dt_opp_mrkt_header.png)

[Dynatrace OpenPipeline](https://docs.dynatrace.com/docs/discover-dynatrace/platform/openpipeline/concepts/data-flow)

Lab tasks:
1. Process OpenTelemetry Collector internal telemetry logs with OpenPipeline
1. Process Astronomy Shop logs with OpenPipeline
1. Process Kubernetes Events logs with OpenPipeline
1. Check Astronomy Shop application health with Unified Service Analysis
