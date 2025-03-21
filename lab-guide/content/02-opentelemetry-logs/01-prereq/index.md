## Prerequisites

### Import Notebook into Dynatrace

[Notebook](https://github.com/dynatrace-wwse/enablement-kubernetes-opentelemetry-openpipeline/blob/main/lab-modules/opentelemetry-logs/opentelemetry-logs_dt_notebook.json)

### Define workshop user variables
In your Github Codespaces Terminal:
```
export DT_ENDPOINT=https://{your-environment-id}.live.dynatrace.com/api/v2/otlp
export DT_API_TOKEN={your-api-token}
export NAME=<INITIALS>-k8s-otel-o11y
```

### Move into the lab module directory
Command:
```sh
cd $base_dir/lab-modules/opentelemetry-logs
```