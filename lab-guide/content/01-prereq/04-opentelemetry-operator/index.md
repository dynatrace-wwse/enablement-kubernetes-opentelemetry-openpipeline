## Deploy OpenTelemetry Operator

### Move to the Base Directory

Command:
```sh
cd $base_dir
```

You should find yourself at the base directory of the repository. If not, then navigate to it.

### Create `dynatrace` namespace
Command:
```sh
kubectl create namespace dynatrace
```

Sample output:
```sh
> namespace/dynatrace created
```

### Create `dynatrace-otelcol-dt-api-credentials` secret

The secret holds the API endpoint and API token that OpenTelemetry data will be sent to.

Command:
```sh
kubectl create secret generic dynatrace-otelcol-dt-api-credentials --from-literal=DT_ENDPOINT=$DT_ENDPOINT --from-literal=DT_API_TOKEN=$DT_API_TOKEN -n dynatrace
```
Sample output:

```sh
> secret/dynatrace-otelcol-dt-api-credentials created
```

### Deploy `cert-manager`, pre-requisite for `opentelemetry-operator`
[Cert Manager](https://cert-manager.io/docs/installation/)

Command:
```sh
kubectl apply -f cluster-manifests/cert-manager.yaml
```
Sample output:
> namespace/cert-manager created\
> customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io created\
> customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io created\
> ...\
> validatingwebhookconfiguration.admissionregistration.k8s.io/cert-manager-webhook created

Wait 30-60 seconds for cert-manager to finish initializing before continuing.

Validate that the Cert Manager components are running.

Command:
```sh
kubectl get pods -n cert-manager
```
Sample output:
| NAME                                       | READY | STATUS  | RESTARTS | AGE |
|--------------------------------------------|-------|---------|----------|-----|
| cert-manager-5f7b5dbfbc-fkpzv              | 1/1   | Running | 0        | 1m  |
| cert-manager-cainjector-7d5b44bb96-kqz7f   | 1/1   | Running | 0        | 1m  |
| cert-manager-webhook-69459b8974-tsmbq      | 1/1   | Running | 0        | 1m  |

### Deploy `opentelemetry-operator`

The OpenTelemetry Operator will deploy and manage the custom resource `OpenTelemetryCollector` deployed on the cluster.

Command:
```sh
kubectl apply -f cluster-manifests/opentelemetry-operator.yaml
```
Sample output:
> namespace/opentelemetry-operator-system created\
> customresourcedefinition.apiextensions.k8s.io/instrumentations.opentelemetry.io created\
> customresourcedefinition.apiextensions.k8s.io/opampbridges.opentelemetry.io created\
> ...\
> validatingwebhookconfiguration.admissionregistration.k8s.io/opentelemetry-operator-validating-webhook-configuration configured

Wait 30-60 seconds for opentelemetry-operator-controller-manager to finish initializing before continuing.

Validate that the OpenTelemetry Operator components are running.

Command:
```sh
kubectl get pods -n opentelemetry-operator-system
```
Sample output:
| NAME                             | READY | STATUS  | RESTARTS | AGE |
|----------------------------------|-------|---------|----------|-----|
| opentelemetry-operator-controller-manager-5d746dbd64-rf9st   | 2/2   | Running | 0        | 1m  |