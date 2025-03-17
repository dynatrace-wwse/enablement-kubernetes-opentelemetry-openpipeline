## OpenTelemetry Collector for Events
https://docs.dynatrace.com/docs/extend-dynatrace/opentelemetry/collector/deployment

The Kubernetes Objects receiver collects, either by pulling or watching, objects from the Kubernetes API server. The most common use case for this receiver is watching Kubernetes events, but it can be used to collect any type of Kubernetes object.

### Add `k8sobjects` receiver to collect Kubernetes events as logs
https://opentelemetry.io/docs/kubernetes/collector/components/#kubernetes-objects-receiver

Our goal is to capture any events related to the `astronomy-shop` and `dynatrace` namespaces.

```yaml
receivers:
  k8sobjects/events:
    auth_type: serviceAccount
    objects:
      - name: events
        mode: watch
        namespaces: [astronomy-shop,dynatrace]
```

The `k8sobjects` receiver is only available on the Contrib Distro of the OpenTelemetry Collector.  Therefore we must deploy a new Collector using the `contrib` image.

### Create `clusterrole` with read access to Kubernetes events

Since the processor uses the Kubernetes API, it needs the correct permission to work correctly. Since service accounts are the only authentication option you must give the service account the proper access. For any object you want to collect you need to ensure the name is added to the cluster role. 

```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: otel-collector-k8s-clusterrole-events
rules:
- apiGroups: [""]
  resources: ["events"]
  verbs: ["get", "watch", "list"]
```
Command:
```sh
kubectl apply -f opentelemetry/rbac/otel-collector-k8s-clusterrole-events.yaml
```
Sample output:
> clusterrole.rbac.authorization.k8s.io/otel-collector-k8s-clusterrole-events created

### Create `clusterrolebinding` for OpenTelemetry Collector service account
```yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: otel-collector-k8s-clusterrole-events-crb
subjects:
- kind: ServiceAccount
  name: dynatrace-events-collector
  namespace: dynatrace
roleRef:
  kind: ClusterRole
  name: otel-collector-k8s-clusterrole-events
  apiGroup: rbac.authorization.k8s.io
```
Command:
```sh
kubectl apply -f opentelemetry/rbac/otel-collector-k8s-clusterrole-events-crb.yaml
```
Sample output:
> clusterrolebinding.rbac.authorization.k8s.io/otel-collector-k8s-clusterrole-events-crb created

### Add `k8sobjects` receiver to collect Kubernetes events as logs
https://opentelemetry.io/docs/kubernetes/collector/components/#kubernetes-objects-receiver
```yaml
receivers:
  k8sobjects/events:
    auth_type: serviceAccount
    objects:
      - name: events
        mode: watch
        namespaces: [astronomy-shop,dynatrace]
```

### Deploy OpenTelemetry Collector - Contrib Distro - Deployment (Gateway)
https://github.com/open-telemetry/opentelemetry-operator

Since the receiver gathers telemetry for the cluster as a whole, only one instance of the receiver is needed across the cluster in order to collect all the data.

```yaml
---
apiVersion: opentelemetry.io/v1alpha1
kind: OpenTelemetryCollector
metadata:
  name: dynatrace-events
  namespace: dynatrace
spec:
  envFrom:
  - secretRef:
      name: dynatrace-otelcol-dt-api-credentials
  mode: "deployment"
  image: "otel/opentelemetry-collector-contrib:0.103.0"
```
Command:
```sh
kubectl apply -f opentelemetry/collector/events/otel-collector-events-crd-01.yaml
```
Sample output:
> opentelemetrycollector.opentelemetry.io/dynatrace-events created

### Validate running pod(s)
Command:
```sh
kubectl get pods -n dynatrace
```
Sample output:
| NAME                             | READY | STATUS  | RESTARTS | AGE |
|----------------------------------|-------|---------|----------|-----|
| dynatrace-events-collector-559d5b9d77-rb26d   | 1/1   | Running | 0        | 1m  |

## Generate Events

### Generate events using deployment scale command
https://kubernetes.io/docs/reference/kubectl/generated/kubectl_scale/

We can generate new Kubernetes events related to the `astronomy-shop` namespace by scaling a deployment up and then scaling it back down.

Command:
```sh
kubectl scale deployment astronomy-shop-imageprovider -n astronomy-shop --replicas=2
```
Sample output:
> deployment.apps/astronomy-shop-imageprovider scaled

Command:
```sh
kubectl scale deployment astronomy-shop-imageprovider -n astronomy-shop --replicas=1
```
Sample output:
> deployment.apps/astronomy-shop-imageprovider scaled

### Query logs in Dynatrace
DQL:
```sql
fetch logs
| filter dynatrace.otel.collector == "dynatrace-events" and event.domain == "k8s" and k8s.resource.name == "events"
| filter object.metadata.namespace == "astronomy-shop"
| sort timestamp desc
| limit 100
| fields timestamp, k8s.cluster.name, {object.metadata.namespace, alias: k8s.namespace.name}, object.message, object.reason, event.name
```
Result:

![dql_k8s_events](../../../assets/images/logs-dql_k8s_events.png)