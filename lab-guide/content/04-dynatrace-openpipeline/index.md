## Dynatrace OpenPipeline
In this lab we'll utilize Dynatrace OpenPipeline to process OpenTelemetry logs at ingest, in order to make them easier to analyze and leverage.  The logs will be ingested by OpenTelemetry Collector, deployed on Kubernetes as part of the previous lab.  The OpenTelemetry Collector logs are output mixed JSON/console format, making them difficult to use by default.  With OpenPipeline, the logs will be processed at ingest, to manipulate fields, extract metrics, and raise alert events in case of any issues.

![OpenPipeline](../../assets/images/dt_opp_mrkt_header.png)

[Dynatrace OpenPipeline](https://docs.dynatrace.com/docs/discover-dynatrace/platform/openpipeline/concepts/data-flow)

OpenPipeline is an architectural component of Dynatrace SaaS.  It resides between the Dynatrace SaaS tenant and [Grail](https://docs.dynatrace.com/docs/discover-dynatrace/platform/grail/dynatrace-grail) data lakehouse.  Logs (,traces, metrics, events, and more) are sent to the Dynatrace SaaS tenant and route through OpenPipeline where they are enriched, transformed, and contextualized prior to being stored in Grail.

Lab tasks:
1. Process OpenTelemetry Collector internal telemetry logs with OpenPipeline
1. Process Astronomy Shop logs with OpenPipeline
1. Process Kubernetes Events logs with OpenPipeline
