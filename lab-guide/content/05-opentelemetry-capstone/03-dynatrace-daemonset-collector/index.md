## Dynatrace Daemonset Collector

### OpenTelemetry Collector - Dynatrace Distro (Daemonset)
https://docs.dynatrace.com/docs/extend-dynatrace/opentelemetry/collector/deployment

Receivers:
`filelog`, `prometheus`

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
https://docs.dynatrace.com/docs/extend-dynatrace/opentelemetry/collector/deployment#tabgroup--dynatrace-docs--agent
```yaml
---
apiVersion: opentelemetry.io/v1alpha1
kind: OpenTelemetryCollector
metadata:
  name: dynatrace-daemonset
  namespace: dynatrace
spec:
  envFrom:
  - secretRef:
      name: dynatrace-otelcol-dt-api-credentials
  mode: "daemonset"
  image: "ghcr.io/dynatrace/dynatrace-otel-collector/dynatrace-otel-collector:latest"
```
Command:
```sh
kubectl apply -f opentelemetry/collector/dynatrace/otel-collector-dynatrace-daemonset-crd.yaml
```
Sample output:
> opentelemetrycollector.opentelemetry.io/dynatrace-daemonset created

### Validate running pod(s)
Command:
```sh
kubectl get pods -n dynatrace
```
Sample output:
| NAME                                       | READY | STATUS  | RESTARTS | AGE |
|--------------------------------------------|-------|---------|----------|-----|
| dynatrace-daemonset-collector-h69pz | 1/1   | Running | 0        | 1m  |