#!/bin/bash

### Preflight Check

# Check if DT_ENDPOINT is set
if [ -z "$DT_ENDPOINT" ]; then
  echo "Error: DT_ENDPOINT is not set."
  exit 1
fi

# Check if DT_API_TOKEN is set
if [ -z "$DT_API_TOKEN" ]; then
  echo "Error: DT_API_TOKEN is not set."
  exit 1
fi

# Check if NAME is set
if [ -z "$NAME" ]; then
  echo "Error: NAME is not set."
  exit 1
fi

echo "All required variables are set."

### Dynatrace Namespace and Secret

# Run the kubectl delete namespace command and capture the output
output=$(kubectl delete namespace dynatrace 2>&1)

# Check if the output contains "not found"
if echo "$output" | grep -q "not found"; then
  echo "Namespace 'dynatrace' was not found."
else
  echo "Namespace 'dynatrace' was found and deleted."
fi

# Create the dynatrace namespace
kubectl create namespace dynatrace

# Create dynatrace-otelcol-dt-api-credentials secret
kubectl create secret generic dynatrace-otelcol-dt-api-credentials --from-literal=DT_ENDPOINT=$DT_ENDPOINT --from-literal=DT_API_TOKEN=$DT_API_TOKEN -n dynatrace

### OpenTelemetry Operator with Cert Manager

# Deploy cert-manager, pre-requisite for opentelemetry-operator
kubectl apply -f opentelemetry/cert-manager.yaml

# Run the kubectl wait command and capture the exit status
kubectl -n cert-manager wait pod --selector=app.kubernetes.io/instance=cert-manager --for=condition=ready --timeout=300s
status=$?

# Check the exit status
if [ $status -ne 0 ]; then
  echo "Error: Pods did not become ready within the timeout period."
  exit 1
else
  echo "Pods are ready."
fi

# Deploy opentelemetry-operator
kubectl apply -f opentelemetry/opentelemetry-operator.yaml

# Run the kubectl wait command and capture the exit status
kubectl -n opentelemetry-operator-system wait pod --selector=app.kubernetes.io/name=opentelemetry-operator --for=condition=ready --timeout=300s
status=$?

# Check the exit status
if [ $status -ne 0 ]; then
  echo "Error: Pods did not become ready within the timeout period."
  exit 1
else
  echo "Pods are ready."
fi

### OpenTelemetry Collectors

# Create clusterrole with read access to Kubernetes objects
kubectl apply -f opentelemetry/rbac/otel-collector-k8s-clusterrole.yaml

# Create clusterrolebinding for OpenTelemetry Collector service accounts
kubectl apply -f opentelemetry/rbac/otel-collector-k8s-clusterrole-crb.yaml

# OpenTelemetry Collector - Dynatrace Distro (Deployment)
kubectl apply -f opentelemetry/collector/dynatrace/otel-collector-dynatrace-deployment-crd.yaml

# OpenTelemetry Collector - Dynatrace Distro (Daemonset)
kubectl apply -f opentelemetry/collector/dynatrace/otel-collector-dynatrace-daemonset-crd.yaml

# OpenTelemetry Collector - Contrib Distro (Deployment)
kubectl apply -f opentelemetry/collector/contrib/otel-collector-contrib-deployment-crd.yaml

# OpenTelemetry Collector - Contrib Distro (Daemonset)
kubectl apply -f opentelemetry/collector/contrib/otel-collector-contrib-daemonset-crd.yaml

# Run the kubectl wait command and capture the exit status
kubectl -n dynatrace wait pod --selector=app.kubernetes.io/component=opentelemetry-collector --for=condition=ready --timeout=300s
status=$?

# Check the exit status
if [ $status -ne 0 ]; then
  echo "Error: Pods did not become ready within the timeout period."
  exit 1
else
  echo "Pods are ready."
fi

### Astronomy Shop

# Customize astronomy-shop helm values
sed -i "s,NAME_TO_REPLACE,$NAME," astronomy-shop/collector-values.yaml

# Update astronomy-shop OpenTelemetry Collector export endpoint via helm
helm upgrade astronomy-shop open-telemetry/opentelemetry-demo --values astronomy-shop/collector-values.yaml --namespace astronomy-shop --version "0.31.0"

# Run the kubectl wait command and capture the exit status
kubectl -n astronomy-shop wait pod --selector=app.kubernetes.io/instance=astronomy-shop --for=condition=ready --timeout=300s
status=$?

# Check the exit status
if [ $status -ne 0 ]; then
  echo "Error: Pods did not become ready within the timeout period."
  exit 1
else
  echo "Pods are ready."
fi

# Complete
echo "Capstone deployment complete!"

