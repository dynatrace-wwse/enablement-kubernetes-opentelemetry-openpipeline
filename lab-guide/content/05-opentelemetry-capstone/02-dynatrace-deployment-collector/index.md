## Dynatrace Deployment Collector

### OpenTelemetry Collector - Dynatrace Distro (Deployment)
https://docs.dynatrace.com/docs/extend-dynatrace/opentelemetry/collector/deployment

Receivers:
`otlp`, `prometheus`

| MODULE        | DT DEPLOY | DT DAEMON | CON DEPLOY | CON DAEMON |
|---------------|-----------|-----------|------------|------------|
| otlp          | - [x]     | - [ ]     | - [x]      | - [ ]      |
| prometheus    | - [x]     | - [x]     | - [x]      | - [x]      |
| filelog       | - [ ]     | - [x]     | - [ ]      | - [ ]      |
| kubeletstats  | - [ ]     | - [ ]     | - [ ]      | - [x]      |
| k8s_cluster   | - [ ]     | - [ ]     | - [x]      | - [ ]      |
| k8sobjects    | - [ ]     | - [ ]     | - [x]      | - [ ]      |

### Deploy Collector

### Deploy OpenTelemetry Collector CRD
https://docs.dynatrace.com/docs/extend-dynatrace/opentelemetry/collector/deployment#tabgroup--dynatrace-docs--gateway
```yaml
---
apiVersion: opentelemetry.io/v1alpha1
kind: OpenTelemetryCollector
metadata:
  name: dynatrace-deployment
  namespace: dynatrace
spec:
  envFrom:
  - secretRef:
      name: dynatrace-otelcol-dt-api-credentials
  mode: "deployment"
  image: "ghcr.io/dynatrace/dynatrace-otel-collector/dynatrace-otel-collector:latest"
```
Command:
```sh
kubectl apply -f opentelemetry/collector/dynatrace/otel-collector-dynatrace-deployment-crd.yaml
```
Sample output:
> opentelemetrycollector.opentelemetry.io/dynatrace-deployment created

### Validate running pod(s)
Command:
```sh
kubectl get pods -n dynatrace
```
Sample output:
| NAME                                       | READY | STATUS  | RESTARTS | AGE |
|--------------------------------------------|-------|---------|----------|-----|
| dynatrace-deployment-collector-796546fbd6-kqflf | 1/1   | Running | 0        | 1m  |