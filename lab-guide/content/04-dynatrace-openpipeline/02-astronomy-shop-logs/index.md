## Astronomy Shop Logs

### Import Notebook into Dynatrace

### Import Dashboard into Dynatrace

### Astronomy Shop Logs - Ondemand Processing at Query Time (Notebook)

The OpenTelemetry Collector deployed as a Daemonset is collecting Pod logs from the Node's filesystem and shipping them to Dynatrace.  The application Pods from the Astronomy Shop application have been instrumented with the OpenTelemetry SDK.  The OpenTelemetry SDK is configured to ship logs (,traces, and metrics) to Dynatrace via the OpenTelemetry Collector deployed as a Deployment (Gateway).  Due to the differences in how these logs are collected, they do not contain the same metadata.  While these logs contain a lot of useful information, they are missing valuable fields/attributes that will make them easier to analyze in context.  These logs can be enriched at ingest, using OpenPipeline.  Additionally, OpenPipeline allows us to process fields, extract new data types, manage permissions, and modify storage retention.

### Goals:
* Add OpenTelemetry service name and namespace
* Enrich SDK logs with additional Kubernetes metadata
* Apply Dynatrace technology bundle (Java)
* Extract data: Payment transaction business event
* Extract metrics: Payment transaction amount

### Add OpenTelemetry Service Name and Namespace
In OpenTelemetry, `service.name` and `service.namespace` are used to provide meaningful context about the services generating telemetry data:

`service.name`: This is the logical name of the service. It should be the same for all instances of a horizontally scaled service. For example, if you have a shopping cart service, you might name it shoppingcart.

`service.namespace`: This is used to group related services together. It helps distinguish a group of services that logically belong to the same system or team. For example, you might use Shop as the namespace for all services related to an online store.

These attributes help in organizing and identifying telemetry data, making it easier to monitor and troubleshoot services within a complex system.

The logs originating from the OpenTelemetry SDK contain both the `service.name` and `service.namespace`.  However, the Pod logs which contain stdout and stderr messages from the containers - do not.  In order to make it easier to analyze the log files and unify the telemetry, the `service.name` and `service.namespace` attributes should be added to the Pod logs with Dynatrace OpenPipeline.

### OpenTelemetry Service Name

Query the `astronomy-shop` logs fitered on `isNull(service.name)`.

DQL:
```sql
fetch logs
| filter matchesValue(k8s.namespace.name,"astronomy-shop") and matchesValue(telemetry.sdk.name,"opentelemetry")
| filter isNull(service.name) and isNotNull(app.label.component) and matchesValue(k8s.namespace.name,"astronomy-shop")
| filterOut matchesValue(k8s.container.name,"istio-proxy")
| sort timestamp desc
| limit 25
| fields timestamp, k8s.namespace.name, k8s.deployment.name, k8s.container.name, app.label.component, service.name, service.namespace
```

The value for `service.name` can be obtained from multiple different fields, but based on the application configuration - it is best to use the value from `app.label.component`.

Use DQL to transform the logs and apply the `service.name` value.

DQL:
```sql
fetch logs
| filter matchesValue(k8s.namespace.name,"astronomy-shop") and matchesValue(telemetry.sdk.name,"opentelemetry")
| filter isNotNull(app.label.component) and matchesValue(k8s.namespace.name,"astronomy-shop")
| filterOut matchesValue(k8s.container.name,"istio-proxy")
| sort timestamp desc
| limit 25
| fieldsAdd service.name = app.label.component
| fields timestamp, k8s.namespace.name, k8s.deployment.name, k8s.container.name, app.label.component, service.name, service.namespace
```

This modifies the log attributes at query time and helps us identify the processing rules for Dynatrace OpenPipeline.  We'll validate the results after OpenPipeline, later.

### OpenTelemetry Service Namespace

Query the `astronomy-shop` logs fitered on `isNull(service.namespace)`.

DQL:
```sql
fetch logs
| filter isNull(service.namespace) and isNotNull(service.name) and isNotNull(app.annotation.service.namespace) and matchesValue(k8s.namespace.name,"astronomy-shop")
| filterOut matchesValue(k8s.container.name,"istio-proxy")
| sort timestamp desc
| limit 25
| fields timestamp, k8s.namespace.name, k8s.deployment.name, k8s.container.name, app.label.component, app.annotation.service.namespace, service.name, service.namespace
```

The Pods have been annotated with the service namespace.  The `k8sattributes` processor has been configured to add this annotation as an attribute, called `app.annotation.service.namespace`.  This field can be used to populate the `service.namespace`.

Use DQL to transform the logs and apply the `service.namespace` value.

DQL:
```sql
fetch logs
| filter isNull(service.namespace) and isNotNull(service.name) and isNotNull(app.annotation.service.namespace) and matchesValue(k8s.namespace.name,"astronomy-shop")
| filterOut matchesValue(k8s.container.name,"istio-proxy")
| sort timestamp desc
| limit 25
| fieldsAdd service.namespace = app.annotation.service.namespace
| fields timestamp, k8s.namespace.name, k8s.deployment.name, k8s.container.name, app.label.component, app.annotation.service.namespace, service.name, service.namespace
```

This modifies the log attributes at query time and helps us identify the processing rules for Dynatrace OpenPipeline.  We'll validate the results after OpenPipeline, later.

### OpenTelemetry SDK Logs

The logs generated and exported by the OpenTelemetry SDK are missing Kubernetes attributes, or in some cases have the wrong values set.  The OpenTelemetry SDK, unless specifically configured otherwise, is not aware of the Kubernetes context in which of the application runs.  As a result, when the OpenTelemetry Collector that's embedded in `astronomy-shop` sends the logs to the Dynatrace OpenTelemtry Collector via OTLP, the Kubernetes attributes are populated with the Kubernetes context of the `astronomy-shop-otelcol` workload.  This makes these attributes unreliable when analyzing logs.  In order to make it easier to analyze the log files and unify the telemetry, the Kubernetes attributes should be correct for the SDK logs with Dynatrace OpenPipeline.

Query the `astronomy-shop` logs filtered on `telemetry.sdk.language` and `astronomy-shop-otelcol`.

DQL:
```sql
fetch logs
| filter isNotNull(telemetry.sdk.language) and matchesValue(k8s.deployment.name,"astronomy-shop-otelcol") and isNotNull(service.name) and matchesValue(k8s.namespace.name,"astronomy-shop")
| sort timestamp desc
| limit 25
| fields timestamp, service.name, telemetry.sdk.language, k8s.namespace.name, k8s.deployment.name, k8s.pod.name, k8s.pod.uid, k8s.replicaset.name, k8s.node.name
```

The `k8s.namespace.name` is correct, however the `k8s.deployment.name`, `k8s.pod.name`, `k8s.pod.uid`, `k8s.replicaset.name`, and `k8s.node.name` are incorrect.  Since the `k8s.deployment.name` is based on the `service.name`, this field can be used to correct the `k8s.deployment.name` value.  The other values can be set to `null` in order to avoid confusion with the `astronomy-shop-otelcol` workload.

Use DQL to transform the logs and set the `k8s.deployment.name` value while clearing the other fields.

DQL:
```sql
fetch logs
| filter isNotNull(telemetry.sdk.language) and matchesValue(k8s.deployment.name,"astronomy-shop-otelcol") and isNotNull(service.name) and matchesValue(k8s.namespace.name,"astronomy-shop")
| sort timestamp desc
| limit 25
| fieldsAdd k8s.deployment.name = concat("astronomy-shop-",service.name)
| fieldsAdd k8s.container.name = service.name
| fieldsAdd app.label.name = concat("astronomy-shop-",service.name)
| fieldsAdd app.label.component = service.name
| fieldsRemove k8s.pod.name, k8s.pod.uid, k8s.replicaset.name, k8s.node.name
| fields timestamp, service.name, telemetry.sdk.language, k8s.namespace.name, k8s.deployment.name, k8s.container.name, app.label.name, app.label.component
```

This modifies the log attributes at query time and helps us identify the processing rules for Dynatrace OpenPipeline.  We'll validate the results after OpenPipeline, later.

### Java Technology Bundle

Many applications written in a specific programming language will utilize known logging frameworks that have standard patterns, fields, and syntax for log messages.  For Java, these include frameworks such as Log4j, Logback, java.util.logging, etc.  Dynatrace OpenPipeline has a wide variety of Technology Processor Bundles, which can be easily added to a Pipeline to help format, clean up, and optimize logs for analysis.

The Java technology processor bundle can be applied to the `astronomy-shop` logs that we know are originating from Java applications.

Query the `astronomy-shop` logs filtered on `telemetry.sdk.language` or the `astronomy-shop-adservice` Java app.

DQL:
```sql
fetch logs
| filter (matchesValue(telemetry.sdk.language,"java", caseSensitive: false) or matchesValue(k8s.deployment.name,"astronomy-shop-adservice", caseSensitive:false)) and matchesValue(k8s.namespace.name,"astronomy-shop")
| sort timestamp desc
| limit 25
| fields timestamp, k8s.namespace.name, k8s.deployment.name, telemetry.sdk.language, content
```

These are the logs that will be modified using the Java technology processor bundle within OpenPipeline.  We'll validate the results after OpenPipeline, later.

### PaymentService Transactions

Most (if not all) applications and microservices drive business processes and outcomes.  Details about the execution of these business processes is often written out to the logs by the application.  Dynatrace OpenPipeline is able to extract this business-relevant information as a business event (bizevent).

[Log to Business Event](https://docs.dynatrace.com/docs/shortlink/ba-business-events-capturing#logs)

DQL is fast and powerful, allowing us to query log files and summarize the data to generate timeseries for dashboards, alerts, AI-driven forecasting and more.  While it's handy to generate timeseries metric data from logs when we didn't know we would need it, it's better to generate timeseries metric data from logs at ingest for the use cases that we know ahead of time.  Dynatrace OpenPipeline is able to extract metric data from logs on ingest.

[Log to Metric](https://docs.dynatrace.com/docs/shortlink/openpipeline-log-processing)

The `paymentservice` component of `astronomy-shop` generates a log record every time it processes a payment transaction successfully.  This information is nested within a `JSON` structured log record, including the transactionId, amount, cardType, and currencyCode.  By parsing these relevant logs for the fields we need, Dynatrace OpenPipeline can be used to generate a payment transaction business event and a payment transaction amount metric on log record ingest.

Query the `astronomy-shop` logs filtered on the `paymentservice` logs with a `trace_id` attribute.

DQL:
```sql
fetch logs
| filter matchesValue(k8s.namespace.name,"astronomy-shop") and matchesValue(service.name,"paymentservice") and matchesValue(k8s.container.name,"paymentservice") and isNotNull(trace_id)
| sort timestamp desc
| limit 25
| fields timestamp, content, k8s.container.name, trace_id
```

The `content` field is structured `JSON`.  The parse command can be used to parse the JSON content and add the fields we need for our use case.

Use DQL to transform the logs and parse the payment fields from the JSON content.

DQL:
```sql
fetch logs
| filter matchesValue(k8s.namespace.name,"astronomy-shop") and matchesValue(service.name,"paymentservice") and matchesValue(k8s.container.name,"paymentservice") and isNotNull(trace_id)
| sort timestamp desc
| limit 25
| fields timestamp, content, k8s.container.name, trace_id
| parse content, "JSON:json_content"
| fieldsAdd app.payment.msg = json_content[`msg`]
| filter app.payment.msg == "Transaction complete."
| fieldsAdd app.payment.cardType = json_content[`cardType`]
| fieldsAdd app.payment.amount = json_content[`amount`][`units`][`low`]
| fieldsAdd app.payment.currencyCode = json_content[`amount`][`currencyCode`]
| fieldsAdd app.payment.transactionId = json_content[`transactionId`]
| fieldsRemove json_content
```

This modifies the log attributes at query time and helps us identify the processing rules for Dynatrace OpenPipeline.  We'll validate the results after OpenPipeline, *next*.

### Create and Configure Dynatrace OpenPipeline

