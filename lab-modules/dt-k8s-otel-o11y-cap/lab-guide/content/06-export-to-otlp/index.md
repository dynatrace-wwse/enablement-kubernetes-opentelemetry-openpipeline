## Export to OTLP Receiver

```yaml
config:
    receivers:
      otlp:
        protocols:
          http:
            # Since this collector needs to receive data from the web, enable cors for all origins
            # `allowed_origins` can be refined for your deployment domain
            cors:
              allowed_origins:
                - "http://*"
                - "https://*"
      httpcheck/frontendproxy:
        targets:
          - endpoint: 'http://{{ include "otel-demo.name" . }}-frontendproxy:8080'

    exporters:
      # Dynatrace OTel Collector
      otlphttp/dynatrace:
        endpoint: http://dynatrace-deployment-collector.dynatrace.svc.cluster.local:4318

    processors:
      resource:
        attributes:
        - key: service.instance.id
          from_attribute: k8s.pod.uid
          action: insert

    connectors:
      spanmetrics: {}

    service:
      pipelines:
        traces:
          receivers: [otlp]
          processors: [memory_limiter, resource, batch]
          exporters: [spanmetrics, otlphttp/dynatrace]
        metrics:
          receivers: [httpcheck/frontendproxy, otlp, spanmetrics]
          processors: [memory_limiter, resource, batch]
          exporters: [otlphttp/dynatrace]
        logs:
          processors: [memory_limiter, resource, batch]
          exporters: [otlphttp/dynatrace]
```