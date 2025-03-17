## Contrib Daemonset Collector

### OpenTelemetry Collector - Contrib Distro (Daemonset)
https://docs.dynatrace.com/docs/extend-dynatrace/opentelemetry/collector/deployment

Receivers:
`prometheus`, `kubeletstats`

| MODULE        | DT DEPLOY | DT DAEMON | CON DEPLOY | CON DAEMON |
|---------------|-----------|-----------|------------|------------|
| otlp          | - [x]     | - [ ]     | - [x]      | - [ ]      |
| prometheus    | - [x]     | - [x]     | - [x]      | - [x]      |
| filelog       | - [ ]     | - [x]     | - [ ]      | - [ ]      |
| kubeletstats  | - [ ]     | - [ ]     | - [ ]      | - [x]      |
| k8s_cluster   | - [ ]     | - [ ]     | - [x]      | - [ ]      |
| k8sobjects    | - [ ]     | - [ ]     | - [x]      | - [ ]      |