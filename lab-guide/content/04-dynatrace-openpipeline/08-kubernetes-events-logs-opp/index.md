## Kubernetes Events Logs - OpenPipeline
Configure Dynatrace OpenPipeline for Kubernetes Events logs.

### Create and Configure Dynatrace OpenPipeline

> ⚠️ If the images are too small and the text is difficult to read, right-click and open the image in a new tab.

> ⚠️ Consider saving your pipeline configuration often to avoid losing any changes.

In your Dynatrace tenant, launch the OpenPipeline app.  Begin by selecting `Logs` from the left-hand menu of telemetry types.  Then choose `Pipelines`.  Click on `+ Pipeline` to add a new pipeline.

![Add Pipeline](../../../assets/images/dt_opp-k8s_events_opp_add_pipeline.png)

Name the new pipeline, `OpenTelemetry Kubernetes Events`.  Click on the `Processing` tab to begin adding `Processor` rules.

![Name Pipeline](../../../assets/images/dt_opp-k8s_events_opp_name_pipeline.png)

### Kubernetes Attributes

Add a processor to set the Kubernetes Attributes.  Click on `+ Processor` to add a new processor.

Type:
```text
DQL
```

Name:
```text
Kubernetes Attributes
```

Matching condition:
```text
isNotNull(object.involvedObject.namespace) and isNotNull(object.involvedObject.kind) and isNotNull(object.involvedObject.name)
```

Processor definition:
```text
fieldsAdd k8s.namespace.name = object.involvedObject.namespace
| fieldsAdd k8s.pod.name = if(object.involvedObject.kind == "Pod",object.involvedObject.name)
| fieldsAdd k8s.deployment.name = if(object.involvedObject.kind == "Deployment",object.involvedObject.name)
| fieldsAdd k8s.replicaset.name = if(object.involvedObject.kind == "ReplicaSet",object.involvedObject.name)
```

![Kubernetes Attributes](../../../assets/images/dt_opp-k8s_events_opp_dql_k8s_attributes.png)

### Kubernetes ReplicaSet

Add a processor to set the values for Kubernetes ReplicaSet.  Click on `+ Processor` to add a new processor.

Type:
```text
DQL
```

Name:
```text
Kubernetes ReplicaSet
```

Matching condition:
```text
isNotNull(object.involvedObject.namespace) and isNotNull(object.involvedObject.name) and matchesValue(object.involvedObject.kind,"ReplicaSet")
```

Processor definition:
```text
parse object.involvedObject.name, "LD:deployment ('-' ALNUM:hash EOS)"
| fieldsAdd k8s.deployment.name = deployment
| fieldsRemove deployment, hash
```

![Kubernetes ReplicaSet](../../../assets/images/dt_opp-k8s_events_opp_dql_k8s_replicaset.png)

### Kubernetes Pod

Add a processor to set the values for Kubernetes Pod.  Click on `+ Processor` to add a new processor.

Type:
```text
DQL
```

Name:
```text
Kubernetes Pod
```

Matching condition:
```text
isNotNull(object.involvedObject.namespace) and isNotNull(object.involvedObject.name) and matchesValue(object.involvedObject.kind,"Pod")
```

Processor definition:
```text
parse object.involvedObject.name, "LD:deployment ('-' ALNUM:hash '-' ALNUM:unique EOS)"
| fieldsAdd k8s.deployment.name = deployment
| fieldsAdd k8s.replicaset.name = concat(deployment,"-",hash)
| fieldsRemove deployment, hash, unique
```

![Kubernetes Pod](../../../assets/images/dt_opp-k8s_events_opp_dql_k8s_pod.png)

### Loglevel and Status

Add a processor to set the Loglevel and Status fields.  Click on `+ Processor` to add a new processor.

Type:
```text
DQL
```

Name:
```text
Loglevel and Status
```

Matching condition:
```text
isNotNull(object.type) and (isNull(loglevel) or matchesValue(loglevel,"NONE")) and (isNull(status) or matchesValue(status,"NONE"))
```

Processor definition:
```text
fieldsAdd loglevel = if(matchesValue(object.type,"Normal"),"INFO", else: if(matchesValue(object.type,"Warning"),"WARN", else: "NONE"))
| fieldsAdd status = if(matchesValue(object.type,"Normal"),"INFO", else: if(matchesValue(object.type,"Warning"),"WARN", else: "NONE"))
```

![Loglevel and Status](../../../assets/images/dt_opp-k8s_events_opp_dql_loglevel.png)

### Content Field

Add a processor to set the content field.  Click on `+ Processor` to add a new processor.

Type:
```text
DQL
```

Name:
```text
Content Field
```

Matching condition:
```text
(matchesValue(content,"") or matchesValue(content," ") or isNull(content)) and isNotNull(object.message)
```

Processor definition:
```text
fieldsAdd content = if(isNull(object.reason), object.message, else:concat(object.reason,": ", object.message))
```

![Content Field](../../../assets/images/dt_opp-k8s_events_opp_dql_content.png)

### Remove Fields

Add a processor to drop the redudant and unnecessary.  Click on `+ Processor` to add a new processor.

Type:
```text
Remove Fields
```

Name:
```text
Drop Fields
```

Matching condition:
```text
isNotNull(object.involvedObject.namespace) and isNotNull(object.involvedObject.kind) and isNotNull(object.involvedObject.name)
```

Remove fields:
| Fields                         |
|--------------------------------|
| object.metadata.name           |
| object.metadata.uid            |
| object.metadata.managedFields  |

![Drop Fields](../../../assets/images/dt_opp-k8s_events_opp_dql_drop_fields.png)

### OpenTelemetry Service Name

Add a processor to set the OpenTelemetry Service Name.  Click on `+ Processor` to add a new processor.

Type:
```text
DQL
```

Name:
```text
OpenTelemetry Service Name
```

Matching condition:
```text
matchesValue(k8s.namespace.name,"astronomy-shop") and isNotNull(k8s.deployment.name) and isNull(service.name)
```

Processor definition:
```text
fieldsAdd split_deployment_name = splitString(k8s.deployment.name,k8s.namespace.name)
| parse split_deployment_name[1], "(PUNCT?) WORD:service.name"
| fieldsRemove split_deployment_name
```

![Service Name](../../../assets/images/dt_opp-k8s_events_opp_service_name.png)

### OpenTelemetry Service Namespace

Add a processor to set the OpenTelemetry Service Namespace.  Click on `+ Processor` to add a new processor.

Type:
```text
Add Fields
```

Name:
```text
OpenTelemetry Service Namespace
```

Matching condition:
```text
matchesValue(k8s.namespace.name,"astronomy-shop") and isNotNull(k8s.deployment.name) and isNotNull(service.name) and isNull(service.namespace)
```

Add fields:
| Field                | Value                         |
|------------------------------------------------------|
| service.namespace    | INITIALS-k8s-otel-o11y        |

*Be sure to use the same `service.namespace` value that you have used elsewhere in this lab!*

![Service Namespace](../../../assets/images/dt_opp-k8s_events_opp_service_namespace.png)

### Kubernetes Event Count

Switch to the `Metric Extraction` tab.

Add a processor to set extract a metric from the Kubernetes event logs.  Click on `+ Processor` to add a new processor.

Type:
```text
Counter metric
```

Name:
```text
Kubernetes Event Count
```

Matching condition:
```text
isNotNull(k8s.cluster.name) and isNotNull(k8s.namespace.name) and isNotNull(status)
```

Metric key:
```text
otel.k8s.event_count
```

Dimensions:
| Fields                         |
|--------------------------------|
| k8s.namespace.name             |
| k8s.cluster.name               |
| status                         |
| service.name                   |

![Kubernetes Event Count](../../../assets/images/dt_opp-k8s_events_opp_metric_event_count.png)

The pipeline is now configured, click on `Save` to save the pipeline configuration.

![Save Pipeline](../../../assets/images/dt_opp-k8s_events_opp_save_pipeline.png)

### Dynamic Route

A pipeline will not have any effect unless logs are configured to be routed to the pipeline.  With dynamic routing, data is routed based on a matching condition. The matching condition is a DQL query that defines the data set you want to route.

Click on `Dynamic Routing` to configure a route to the target pipeline.  Click on `+ Dynamic Route` to add a new route.

![Add Route](../../../assets/images/dt_opp-k8s_events_opp_add_route.png)

Configure the `Dynamic Route` to use the `OpenTelemetry Kubernetes Events` pipeline.

Name:
```text
OpenTelemetry Kubernetes Events
```

Matching condition:
```text
matchesValue(telemetry.sdk.name,"opentelemetry") and matchesValue(event.domain,"k8s") and matchesValue(k8s.resource.name,"events")
```

Pipeline:
```text
OpenTelemetry Kubernetes Events
```

Click `Add` to add the route.

![Configure Route](../../../assets/images/dt_opp-k8s_events_opp_configure_route.png)

Validate that the route is enabled in the `Status` column.  Click on `Save` to save the dynamic route table configuration.

![Save Routes](../../../assets/images/dt_opp-k8s_events_opp_save_routes.png)

Changes will typically take effect within a couple of minutes.

### Generate Kubernetes Events

Kubernetes Events will only be generated when Kubernetes orchestration causes changes within the environment.  Generate new Kubernetes Events for analysis prior to continuing.

Command:
```text
kubectl delete pods -n astronomy-shop --field-selector="status.phase=Running"
```

This will delete all running pods for `astronomy-shop` and schedule new ones, resulting in many new Kubernetes Events.