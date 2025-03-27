## Astronomy Shop Logs - Analyze
Analyze the Astronomy Shop logs after Dynatrace OpenPipeline processing.

### Analyze the results in Dynatrace (Notebook)

Use the Notebook from earlier to analyze the results.

### OpenTelemetry Service Name

Query the `astronomy-shop` logs fitered on `isNotNull(service.name)` to analyze with `OpenTelemetry Service Name`.

DQL: After OpenPipeline
```sql
fetch logs
| filter matchesValue(k8s.namespace.name,"astronomy-shop") and matchesValue(telemetry.sdk.name,"opentelemetry")
| filter isNotNull(service.name) and isNotNull(app.label.component) and matchesValue(k8s.namespace.name,"astronomy-shop")
| filterOut matchesValue(k8s.container.name,"istio-proxy")
| sort timestamp desc
| limit 25
| fields timestamp, k8s.namespace.name, k8s.deployment.name, k8s.container.name, app.label.component, service.name, service.namespace
```

![Service Name](../../../assets/images/dt_opp-astronomy_shop_analyze_service_name.png)

### OpenTelemetry Service Namespace

Query the `astronomy-shop` logs fitered on `isNotNull(service.namespace)` to analyze with `OpenTelemetry Service Namespace`.

DQL: After OpenPipeline
```sql
fetch logs
| filter isNotNull(service.namespace) and isNotNull(service.name) and isNotNull(app.annotation.service.namespace) and matchesValue(k8s.namespace.name,"astronomy-shop")
| filterOut matchesValue(k8s.container.name,"istio-proxy")
| sort timestamp desc
| limit 25
| fields timestamp, k8s.namespace.name, k8s.deployment.name, k8s.container.name, app.label.component, app.annotation.service.namespace, service.name, service.namespace
```

![Service Name](../../../assets/images/dt_opp-astronomy_shop_analyze_service_namespace.png)

### OpenTelemetry SDK Logs

Query the `astronomy-shop` logs fitered on `telemetry.sdk.language` to analyze with `OpenTelemetry SDK Logs`.

DQL: After OpenPipeline
```sql
fetch logs
| filter isNotNull(telemetry.sdk.language) and isNotNull(service.name) and matchesValue(k8s.namespace.name,"astronomy-shop")
| sort timestamp desc
| limit 25
| fields timestamp, service.name, telemetry.sdk.language, k8s.namespace.name, k8s.deployment.name, k8s.container.name, app.label.name, app.label.component, k8s.pod.name, k8s.pod.uid, k8s.replicaset.name, k8s.node.name
```

![Service Name](../../../assets/images/dt_opp-astronomy_shop_analyze_sdk_logs.png)

### Java Technology Bundle

Query the `astronomy-shop` logs fitered on `telemetry.sdk.language == "java"` to analyze with `Java Technology Bundle` logs.

DQL: After OpenPipeline
```sql
fetch logs
| filter (matchesValue(telemetry.sdk.language,"java", caseSensitive: false) or matchesValue(k8s.deployment.name,"astronomy-shop-adservice", caseSensitive:false)) and matchesValue(k8s.namespace.name,"astronomy-shop")
| filterOut matchesValue(k8s.container.name,"istio-proxy")
| sort timestamp desc
| limit 50
```

![Service Name](../../../assets/images/dt_opp-astronomy_shop_analyze_java_logs.png)

You likely won't notice anything different about these logs.  This exercise was meant to show you how to use the technology bundles.

### PaymentService Transactions

Query the `astronomy-shop` logs fitered on `service.name == "paymentservice"` to analyze with `PaymentService` logs.

DQL: After OpenPipeline
```sql
fetch logs
| filter matchesValue(k8s.namespace.name,"astronomy-shop") and isNotNull(service.name)
| filterOut event.domain == "k8s"
| filter matchesValue(service.name,"paymentservice") and matchesValue(k8s.container.name,"paymentservice") and isNotNull(trace_id)
| sort timestamp desc
| limit 25
| fields timestamp, content, k8s.container.name, trace_id, app.payment.msg, app.payment.cardType, app.payment.amount, app.payment.currencyCode, app.payment.transactionId
```

![Service Name](../../../assets/images/dt_opp-astronomy_shop_analyze_paymentservice_logs.png)

Query the `PaymentService` Business Events.

DQL: PaymentService Transaction Business Events
```sql
fetch bizevents
| filter matchesValue(event.type,"astronomy-shop.app.payment.complete")
| sort timestamp desc
| limit 10
```

![Service Name](../../../assets/images/dt_opp-astronomy_shop_analyze_paymentservice_bizevents.png)

Query the `PaymentService` Metric.

DQL: PaymentService Transaction Extracted Metric
```sql
timeseries sum(`log.otel.astronomy-shop.app.payment.amount`), by: { currencyCode, cardType }
| fieldsAdd value.A = arrayAvg(`sum(\`log.otel.astronomy-shop.app.payment.amount\`)`)
```

![Service Name](../../../assets/images/dt_opp-astronomy_shop_analyze_paymentservice_metric.png)

### Import Dashboard into Dynatrace