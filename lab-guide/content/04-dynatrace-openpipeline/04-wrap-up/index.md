## Wrap Up

### What You Learned Today

By completing this lab, you've successfully set up Dynatrace OpenPipeline pipelines to process the OpenTelemetry logs at ingest.

- OpenTelemetry Collector logs
    * Parse JSON structured content field to easily filter, aggregate, and analyze on nested fields
    * Set loglevel and status fields to easily identify errors with the OpenTelemetry Collector
    * Remove unwanted fields/attributes to reduce log bloat and optimize queries
    * Extract metrics: successful data points to track OpenTelemetry Collector health and reduce heavy log queries
    * Extract metrics: dropped data points to track OpenTelemetry Collector health and reduce heavy log queries
    * Alert: zero data points to be alerted on OpenTelemetry Collector health issues
- Astronomy Shop logs
    * Add OpenTelemetry service name and namespace fields to unify telemetry signals and enable out-of-the-box analysis
    * Enrich SDK logs with additional Kubernetes metadata to unify telemetry signals and analyze Kubernetes context
    * Apply Dynatrace technology bundle (Java) to transform logs based on known Java standards and frameworks
    * Extract data: Payment transaction business event to measure business outcomes and link them to system health
    * Extract metrics: Payment transaction amount to measure business KPIs and link them to system health
- Kubernetes Events logs
    * Enrich logs with additional Kubernetes metadata to unify telemetry signals and analyze Kubernetes context
    * Enrich the content field to fit logging standards and semantics
    * Set loglevel and status fields to easily identify errors with Kubernetes context
    * Remove unwanted fields/attributes to reduce log bloat and optimize queries
    * Add OpenTelemetry service name and namespace to unify telemetry signals and enable out-of-the-box analysis
    * Extract metrics: event count to track Kubernetes health and reduce heavy log queries