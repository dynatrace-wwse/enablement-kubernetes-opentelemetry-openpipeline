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

### Export to OTLP Receiver

### Export OpenTelemetry data from `astronomy-shop` to OpenTelemetry Collector - Dynatrace Distro (Deployment)

### Customize astronomy-shop helm values
```yaml
default:
  # List of environment variables applied to all components
  env:
    - name: OTEL_SERVICE_NAME
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: "metadata.labels['app.kubernetes.io/component']"
    - name: OTEL_COLLECTOR_NAME
      value: '{{ include "otel-demo.name" . }}-otelcol'
    - name: OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE
      value: cumulative
    - name: OTEL_RESOURCE_ATTRIBUTES
      value: 'service.name=$(OTEL_SERVICE_NAME),service.namespace=NAME_TO_REPLACE,service.version={{ .Chart.AppVersion }}'
```
> service.namespace=NAME_TO_REPLACE\
> service.namespace=INITIALS-k8s-otel-o11y

Command:
```sh
sed -i "s,NAME_TO_REPLACE,$NAME," astronomy-shop/collector-values.yaml
```

### Update `astronomy-shop` OpenTelemetry Collector export endpoint via helm
Command:
```sh
helm upgrade astronomy-shop open-telemetry/opentelemetry-demo --values astronomy-shop/collector-values.yaml --namespace astronomy-shop --version "0.31.0"
```
Sample output:
> NAME: astronomy-shop\
> LAST DEPLOYED: Thu Jun 27 20:58:38 2024\
> NAMESPACE: astronomy-shop\
> STATUS: deployed\
> REVISION: 2

### Analyze Data in Dynatrace

### Analyze metrics, traces, and logs in Dynatrace dashboard
![astronomy-shop dashboard](../../../assets/images/capstone-dt_astronomy_shop_dashboard.png)
[astronomy-shop dashboard](https://github.com/dynatrace-wwse/enablement-kubernetes-opentelemetry/blob/main/lab-modules/dt-k8s-otel-o11y-cap/dt-k8s-otel-o11y-cap_dt_dashboard.json)