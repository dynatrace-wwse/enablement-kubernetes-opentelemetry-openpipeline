## Prerequisites

### Import Notebook into Dynatrace

[Notebook](https://github.com/dynatrace-wwse/enablement-kubernetes-opentelemetry/blob/main/lab-modules/dt-k8s-otel-o11y-logs/dt-k8s-otel-o11y-logs_dt_notebook.json)

### Define workshop user variables
In your Github Codespaces Terminal:
```
export DT_ENDPOINT=https://{your-environment-id}.live.dynatrace.com/api/v2/otlp
export DT_API_TOKEN={your-api-token}
export NAME=<INITIALS>-k8s-otel-o11y
```

### Move into the base directory
Command:
```sh
cd -
cd lab-modules/dt-k8s-otel-o11y-logs
```