#!/bin/bash
# This file contains the functions for installing Kubernetes-Play.
# Each function contains a boolean flag so the installations
# can be highly customized.
# Original file located https://github.com/dynatrace-wwse/kubernetes-playground/blob/main/cluster-setup/functions.sh

# ======================================================================
#          ------- Util Functions -------                              #
#  A set of util functions for logging, validating and                 #
#  executing commands.                                                 #
# ======================================================================

# VARIABLES DECLARATION
source /workspaces/$RepositoryName/.devcontainer/util/variables.sh

# FUNCTIONS DECLARATIONS
timestamp() {
  date +"[%Y-%m-%d %H:%M:%S]"
}

printInfo() {
  echo -e "${GREEN}[$LOGNAME| ${BLUE}INFO${CYAN} |$(timestamp) ${LILA}|${RESET} $1 ${LILA}|"
}

printInfoSection() {
  echo -e "${GREEN}[$LOGNAME| ${BLUE}INFO${CYAN} |$(timestamp) ${LILA}|$thickline"
  echo -e "${GREEN}[$LOGNAME| ${BLUE}INFO${CYAN} |$(timestamp) ${LILA}|$halfline ${RESET}$1${LILA} $halfline"
  echo -e "${GREEN}[$LOGNAME| ${BLUE}INFO${CYAN} |$(timestamp) ${LILA}|$thinline"
}

printWarn() {
  echo -e "${GREEN}[$LOGNAME| ${YELLOW}WARN${GREEN} |$(timestamp) ${LILA}|  ${RESET}$1${LILA}  |"
}

printError() {
  echo -e "${GREEN}[$LOGNAME| ${RED}ERROR${GREEN} |$(timestamp) ${LILA}|  ${RESET}$1${LILA}  |"
}

postCodespaceTracker(){
  # Set demo name
  if [[ $# -eq 1 ]]; then
    DEMOPLACEHOLDER="demo-$1"
  else
    namespace_filter="demo-placeholder"
  fi
  curl -X POST https://grzxx1q7wd.execute-api.us-east-1.amazonaws.com/default/codespace-tracker \
  -H "Content-Type: application/json" \
  -d "{
  \"repo\": \"$GITHUB_REPOSITORY\",
  \"demo\": \"$DEMOPLACEHOLDER\",
  \"codespace.name\": \"$CODESPACE_NAME\"
  }"
}

printGreeting(){
  bash $CODESPACE_VSCODE_FOLDER/.devcontainer/util/greeting.sh
}

# shellcheck disable=SC2120
waitForAllPods() {
  # Function to filter by Namespace, default is ALL
  if [[ $# -eq 1 ]]; then
    namespace_filter="-n $1"
  else
    namespace_filter="--all-namespaces"
  fi
  RETRY=0
  RETRY_MAX=60
  # Get all pods, count and invert the search for not running nor completed. Status is for deleting the last line of the output
  CMD="kubectl get pods $namespace_filter 2>&1 | grep -c -v -E '(Running|Completed|Terminating|STATUS)'"
  printInfo "Checking and wait for all pods in \"$namespace_filter\" to run."
  while [[ $RETRY -lt $RETRY_MAX ]]; do
    pods_not_ok=$(eval "$CMD")
    if [[ "$pods_not_ok" == '0' ]]; then
      printInfo "All pods are running."
      break
    fi
    RETRY=$(($RETRY + 1))
    printWarn "Retry: ${RETRY}/${RETRY_MAX} - Wait 10s for $pods_not_ok pods to finish or be in state Running ..."
    sleep 10
  done

  if [[ $RETRY == $RETRY_MAX ]]; then
    printError "Following pods are not still not running. Please check their events. Exiting installation..."
    kubectl get pods --field-selector=status.phase!=Running -A
    exit 1
  fi
}

waitForAllReadyPods() {
  # Function to filter by Namespace, default is ALL
  if [[ $# -eq 1 ]]; then
    namespace_filter="-n $1"
  else
    namespace_filter="--all-namespaces"
  fi
  RETRY=0
  RETRY_MAX=60
  # Get all pods, count and invert the search for not running nor completed. Status is for deleting the last line of the output
  CMD="kubectl get pods $namespace_filter 2>&1 | grep -c -v -E '(1\/1|2\/2|3\/3|4\/4|5\/5|6\/6|READY)'"
  printInfo "Checking and wait for all pods in \"$namespace_filter\" to be running and ready (max of 6 containers per pod)"
  while [[ $RETRY -lt $RETRY_MAX ]]; do
    pods_not_ok=$(eval "$CMD")
    if [[ "$pods_not_ok" == '0' ]]; then
      printInfo "All pods are running."
      break
    fi
    RETRY=$(($RETRY + 1))
    printWarn "Retry: ${RETRY}/${RETRY_MAX} - Wait 10s for $pods_not_ok pods to finish or be in state Ready & Running ..."
    sleep 10
  done

  if [[ $RETRY == $RETRY_MAX ]]; then
    printError "Following pods are not still not running. Please check their events. Exiting installation..."
    kubectl get pods --field-selector=status.phase!=Running -A
    exit 1
  fi
}

installHelm() {
  # https://helm.sh/docs/intro/install/#from-script
  printInfoSection " Installing Helm"
  cd /tmp
  sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  sudo chmod 700 get_helm.sh
  sudo /tmp/get_helm.sh

  printInfoSection "Helm version"
  helm version

  # https://helm.sh/docs/intro/quickstart/#initialize-a-helm-chart-repository
  printInfoSection "Helm add Bitnami repo"
  printInfoSection "helm repo add bitnami https://charts.bitnami.com/bitnami"
  helm repo add bitnami https://charts.bitnami.com/bitnami

  printInfoSection "Helm repo update"
  helm repo update

  printInfoSection "Helm search repo bitnami"
  helm search repo bitnami
}

installHelmDashboard() {

  printInfoSection "Installing Helm Dashboard"
  helm plugin install https://github.com/komodorio/helm-dashboard.git

  printInfoSection "Running Helm Dashboard"
  helm dashboard --bind=0.0.0.0 --port 8002 --no-browser --no-analytics >/dev/null 2>&1 &

}

installKubernetesDashboard() {
  # https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
  printInfoSection " Installing Kubernetes dashboard"

  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
  helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

  # In the functions you can specify the amount of retries and the NS
  # shellcheck disable=SC2119
  waitForAllPods
  printInfoSection "kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8001:443 --address=\"0.0.0.0\", (${attempts}/${max_attempts}) sleep 10s"
  kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8001:443 --address="0.0.0.0" >/dev/null 2>&1 &
  # https://github.com/komodorio/helm-dashboard

  # Do we need this?
  printInfoSection "Create ServiceAccount and ClusterRoleBinding"
  kubectl apply -f /app/.devcontainer/etc/k3s/dashboard-adminuser.yaml
  kubectl apply -f /app/.devcontainer/etc/k3s/dashboard-rolebind.yaml

  printInfoSection "Get admin-user token"
  kubectl -n kube-system create token admin-user --duration=8760h
}

installK9s() {
  printInfoSection "Installing k9s CLI"
  curl -sS https://webinstall.dev/k9s | bash
}

bindFunctionsInShell() {
  printInfoSection "Binding functions.sh and adding a Greeting in the .zshrc for user $USER "
  echo "
# Loading all this functions in CLI
source $CODESPACE_VSCODE_FOLDER/.devcontainer/util/functions.sh

#print greeting everytime a Terminal is opened
printGreeting
" >> /"$HOME"/.zshrc

}

setupAliases() {
  printInfoSection "Adding Bash and Kubectl Pro CLI aliases to the end of the .zshrc for user $USER "
  echo "
# Alias for ease of use of the CLI
alias las='ls -las' 
alias c='clear' 
alias hg='history | grep' 
alias h='history' 
alias gita='git add -A'
alias gitc='git commit -s -m'
alias gitp='git push'
alias gits='git status'
alias gith='git log --graph --pretty=\"%C(yellow)[%h] %C(reset)%s by %C(green)%an - %C(cyan)%ad %C(auto)%d\" --decorate --all --date=human'
alias vaml='vi -c \"set syntax:yaml\" -' 
alias vson='vi -c \"set syntax:json\" -' 
alias pg='ps -aux | grep' 
" >> /"$HOME"/.zshrc
}

installRunme() {
  printInfoSection "Installing Runme Version $RUNME_CLI_VERSION"
  mkdir runme_binary
  wget -O runme_binary/runme_linux_x86_64.tar.gz https://download.stateful.com/runme/${RUNME_CLI_VERSION}/runme_linux_x86_64.tar.gz
  tar -xvf runme_binary/runme_linux_x86_64.tar.gz --directory runme_binary
  sudo mv runme_binary/runme /usr/local/bin
  rm -rf runme_binary
}

createKindCluster() {
  
  printInfoSection "Installing Kubernetes Cluster (Kind)"
  # Create k8s cluster
  kind create cluster --config "$CODESPACE_VSCODE_FOLDER/.devcontainer/kind-cluster.yml" --wait 5m
}

certmanagerInstall() {
  printInfoSection "Install CertManager $CERTMANAGER_VERSION"
  kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v$CERTMANAGER_VERSION/cert-manager.yaml
  # shellcheck disable=SC2119
  waitForAllPods cert-manager
}

generateRandomEmail() {
  echo "email-$RANDOM-$RANDOM@dynatrace.ai"
}

certmanagerEnable() {
  printInfoSection "Installing ClusterIssuer with HTTP Letsencrypt "

  if [ -n "$CERTMANAGER_EMAIL" ]; then
    printInfo "Creating ClusterIssuer for $CERTMANAGER_EMAIL"
    # Simplecheck to check if the email address is valid
    if [[ $CERTMANAGER_EMAIL == *"@"* ]]; then
      echo "Email address is valid! - $CERTMANAGER_EMAIL"
      EMAIL=$CERTMANAGER_EMAIL
    else
      echo "Email address $CERTMANAGER_EMAIL is not valid. Email will be generated"
      EMAIL=$(generateRandomEmail)
    fi
  else
    echo "Email not passed.  Email will be generated"
    EMAIL=$(generateRandomEmail)
  fi

  printInfo "EmailAccount for ClusterIssuer $EMAIL, creating ClusterIssuer"
  cat $CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/clusterissuer.yaml | sed 's~email.placeholder~'"$EMAIL"'~' >$CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/gen/clusterissuer.yaml

  kubectl apply -f $CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/gen/clusterissuer.yaml

  printInfo "Let's Encrypt Process in kubectl for CertManager"
  printInfo " For observing the creation of the certificates: \n
              kubectl describe clusterissuers.cert-manager.io -A
              kubectl describe issuers.cert-manager.io -A
              kubectl describe certificates.cert-manager.io -A
              kubectl describe certificaterequests.cert-manager.io -A
              kubectl describe challenges.acme.cert-manager.io -A
              kubectl describe orders.acme.cert-manager.io -A
              kubectl get events
              "

  waitForAllPods cert-manager
  # Not needed
  #bashas "cd $K8S_PLAY_DIR/cluster-setup/resources/ingress && bash add-ssl-certificates.sh"
}

saveReadCredentials() {

  printInfo "If credentials are passed as arguments they will be overwritten and saved as ConfigMap"
  printInfo "else they will be read from the ConfigMap and exported as env Variables"

  if [[ $# -eq 3 ]]; then
    DT_TENANT=$1
    DT_OPERATOR_TOKEN=$2
    DT_INGEST_TOKEN=$3

    printInfo "Saving the credentials ConfigMap dtcredentials -n default with following arguments supplied: @"
    kubectl delete configmap -n default dtcredentials 2>/dev/null

    kubectl create configmap -n default dtcredentials \
      --from-literal=tenant=${DT_TENANT} \
      --from-literal=apiToken=${DT_OPERATOR_TOKEN} \
      --from-literal=dataIngestToken=${DT_INGEST_TOKEN}

  else
    printInfo "No arguments passed, getting them from the ConfigMap"

    kubectl get configmap -n default dtcredentials 2>/dev/null
    # Getting the data size
    data=$(kubectl get configmap -n default dtcredentials | awk '{print $2}')
    # parsing to number
    size=$(echo $data | grep -o '[0-9]*')
    printInfo "The Configmap has $size variables stored"
    if [[ $? -eq 0 ]]; then
      DT_TENANT=$(kubectl get configmap -n default dtcredentials -ojsonpath={.data.tenant})
      DT_OPERATOR_TOKEN=$(kubectl get configmap -n default dtcredentials -ojsonpath={.data.apiToken})
      DT_INGEST_TOKEN=$(kubectl get configmap -n default dtcredentials -ojsonpath={.data.dataIngestToken})

    else
      printInfo "ConfigMap not found, resetting variables"
      unset DT_TENANT DT_OPERATOR_TOKEN DT_INGEST_TOKEN
    fi
  fi
  printInfo "Dynatrace Tenant: $DT_TENANT"
  printInfo "Dynatrace API & PaaS Token: $DT_OPERATOR_TOKEN"
  printInfo "Dynatrace Ingest Token: $DT_INGEST_TOKEN"
  printInfo "Dynatrace Otel API Token: $DT_INGEST_TOKEN"
  printInfo "Dynatrace Otel Endpoint: $DT_OTEL_ENDPOINT"

  export DT_TENANT=$DT_TENANT
  export DT_OPERATOR_TOKEN=$DT_OPERATOR_TOKEN
  export DT_INGEST_TOKEN=$DT_INGEST_TOKEN
  export DT_INGEST_TOKEN=$DT_INGEST_TOKEN
  export DT_OTEL_ENDPOINT=$DT_OTEL_ENDPOINT

}

# FIXME: Clean up this mess
dynatraceEvalReadSaveCredentials() {
  printInfoSection "Dynatrace evaluating and reading/saving Credentials"
  if [[ -n "${DT_TENANT}" && -n "${DT_INGEST_TOKEN}" ]]; then
    DT_TENANT=$DT_TENANT
    DT_OPERATOR_TOKEN=$DT_OPERATOR_TOKEN
    DT_INGEST_TOKEN=$DT_INGEST_TOKEN
    DT_OTEL_ENDPOINT=$DT_TENANT/api/v2/otlp
    
    printInfo "--- Variables set in the environment with Otel config, overriding & saving them ------"
    printInfo "Dynatrace Tenant: $DT_TENANT"
    printInfo "Dynatrace API Token: $DT_OPERATOR_TOKEN"
    printInfo "Dynatrace Ingest Token: $DT_INGEST_TOKEN"
    printInfo "Dynatrace Otel Endpoint: $DT_OTEL_ENDPOINT"

    saveReadCredentials $DT_TENANT $DT_OPERATOR_TOKEN $DT_INGEST_TOKEN

  elif [[ $# -eq 3 ]]; then
    DT_TENANT=$1
    DT_OPERATOR_TOKEN=$2
    DT_INGEST_TOKEN=$3
    printInfo "--- Variables passed as arguments, overriding & saving them ------"
    printInfo "Dynatrace Tenant: $DT_TENANT"
    printInfo "Dynatrace API Token: $DT_OPERATOR_TOKEN"
    printInfo "Dynatrace Ingest Token: $DT_INGEST_TOKEN"
    saveReadCredentials $DT_TENANT $DT_OPERATOR_TOKEN $DT_INGEST_TOKEN

  elif [[ -n "${DT_TENANT}" ]]; then
    DT_TENANT=$DT_TENANT
    DT_OPERATOR_TOKEN=$DT_OPERATOR_TOKEN
    DT_INGEST_TOKEN=$DT_INGEST_TOKEN
    printInfo "--- Variables set in the environment, overriding & saving them ------"
    printInfo "Dynatrace Tenant: $DT_TENANT"
    printInfo "Dynatrace API Token: $DT_OPERATOR_TOKEN"
    printInfo "Dynatrace Ingest Token: $DT_INGEST_TOKEN"
    saveReadCredentials $DT_TENANT $DT_OPERATOR_TOKEN $DT_INGEST_TOKEN
  else
    printInfoSection "Dynatrace Variables not passed, reading them"
    saveReadCredentials
  fi
}

deployCloudNative() {
  printInfoSection "Deploying Dynatrace in CloudNativeFullStack mode for $DT_TENANT"
  if [ -n "${DT_TENANT}" ]; then
    # Check if the Webhook has been created and is ready
    kubectl -n dynatrace wait pod --for=condition=ready --selector=app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/component=webhook --timeout=300s

    kubectl -n dynatrace apply -f $CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/gen/dynakube-cloudnative.yaml

    printInfo "Log capturing will be handled by the Host agent."
    # We wait for 5 seconds for the pods to be scheduled, otherwise it will mark it as passed since the pods have not been scheduled
    sleep 5
    waitForAllPods dynatrace
    #if the app needs the AG or OS agent for some reason, then you'll need to wait for AG/OS to be ready, this function does that.
    #waitForAllReadyPods dynatrace
  else
    printInfo "Not deploying the Dynatrace Operator, no credentials found"
  fi
}

deployApplicationMonitoring() { 
  printInfoSection "Deploying Dynatrace in ApplicationMonitoring mode for $DT_TENANT"
  if [ -n "${DT_TENANT}" ]; then
    # Check if the Webhook has been created and is ready
    kubectl -n dynatrace wait pod --for=condition=ready --selector=app.kubernetes.io/name=dynatrace-operator,app.kubernetes.io/component=webhook --timeout=300s

    kubectl -n dynatrace apply -f $CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/gen/dynakube-applicationmonitoring.yaml
    #FIXME: When deploying in AppOnly we need to capture the logs, either with log module or FluentBit
    waitForAllPods dynatrace
  else
    printInfo "Not deploying the Dynatrace Operator, no credentials found"
  fi
}

undeployDynakubes() {
    printInfoSection "Undeploying Dynakubes, OneAgent installation from Workernode if installed"

    kubectl -n dynatrace delete dynakube --all
    #FIXME: Test uninstalling Dynatracem good when changing monitoring modes. 
    #kubectl -n dynatrace wait pod --for=condition=delete --selector=app.kubernetes.io/name=oneagent,app.kubernetes.io/managed-by=dynatrace-operator --timeout=300s
    sudo bash /opt/dynatrace/oneagent/agent/uninstall.sh 2>/dev/null
}

uninstallDynatrace() {
    echo "Uninstalling Dynatrace"
    undeployDynakubes

    echo "Uninstalling Dynatrace"
    helm uninstall dynatrace-operator -n dynatrace

    kubectl delete namespace dynatrace
}

# shellcheck disable=SC2120
dynatraceDeployOperator() {

  printInfoSection "Deploying Dynatrace Operator via Helm."
  # posssibility to load functions.sh and call dynatraceDeployOperator A B C to save credentials and override
  # or just run in normal deployment
  saveReadCredentials $@
  # new lines, needed for workflow-k8s-playground, cluster in dt needs to have the name k8s-playground-{requestuser} to be able to spin up multiple instances per tenant

  if [ -n "${DT_TENANT}" ]; then
    # Deploy Operator

    deployOperatorViaHelm
    waitForAllPods dynatrace

    #FIXME: Add Ingress Nginx instrumentation and always expose in a port so all apps have RUM regardless of technology
    #printInfoSection "Instrumenting NGINX Ingress"
    #bashas "cd $K8S_PLAY_DIR/apps/nginx && bash instrument-nginx.sh"

  else
    printInfo "Not deploying the Dynatrace Operator, no credentials found"
  fi
}




generateDynakube(){
    # Generate DynaKubeSkel with API URL
    sed -e 's~apiUrl: https://ENVIRONMENTID.live.dynatrace.com/api~apiUrl: '"$DT_API_URL"'~' $CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/dynakube-skel.yaml > $CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/gen/dynakube-skel.yaml

    # ClusterName for API
    sed -i 's~feature.dynatrace.com/automatic-kubernetes-api-monitoring-cluster-name: "CLUSTERNAME"~feature.dynatrace.com/automatic-kubernetes-api-monitoring-cluster-name: "'"$CLUSTERNAME"'"~g' $CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/gen/dynakube-skel.yaml
    # Networkzone
    sed -i 's~networkZone: CLUSTERNAME~networkZone: '$CLUSTERNAME'~g' $CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/gen/dynakube-skel.yaml
    # HostGroup
    sed -i 's~hostGroup: CLUSTERNAME~hostGroup: '$CLUSTERNAME'~g' $CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/gen/dynakube-skel.yaml
    # ActiveGate Group
    sed -i 's~group: CLUSTERNAME~group: '$CLUSTERNAME'~g' $CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/gen/dynakube-skel.yaml

    # Create Dynakube for CloudNative 
    sed -e 's~MONITORINGMODE:~cloudNativeFullStack:~' $CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/gen/dynakube-skel.yaml > $CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/gen/dynakube-cloudnative.yaml
    
    # Create Dynakube for ApplicationMonitoring
    sed -e 's~MONITORINGMODE:~applicationMonitoring: {}:~' $CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/gen/dynakube-skel.yaml > $CODESPACE_VSCODE_FOLDER/.devcontainer/yaml/gen/dynakube-applicationmonitoring.yaml

}

deployOperatorViaHelm(){

  saveReadCredentials
  API="/api"
  DT_API_URL=$DT_TENANT$API
  
  # Read the actual hostname in case changed during instalation
  CLUSTERNAME=$(hostname)

  helm install dynatrace-operator oci://public.ecr.aws/dynatrace/dynatrace-operator --create-namespace --namespace dynatrace --atomic

  # Save Dynatrace Secret
  kubectl -n dynatrace create secret generic dev-container --from-literal="apiToken=$DT_OPERATOR_TOKEN" --from-literal="dataIngestToken=$DT_INGEST_TOKEN"

  generateDynakube

}


deployTodoApp(){
  printInfoSection "Deploying Todo App"

  kubectl create ns todoapp

  # Create deployment of todoApp
  kubectl -n todoapp create deploy todoapp --image=shinojosa/todoapp:1.0.0

  # Expose deployment of todoApp with a Service
  kubectl -n todoapp expose deployment todoapp --type=NodePort --port=8080 --name todoapp 

  # Define the NodePort to expose the app from the Cluster
  kubectl patch service todoapp --namespace=todoapp --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":30100}]'

  printInfoSection "TodoApp is available via NodePort=30080"

}

exposeApp(){
  printInfo "Exposing App in your dev.container"
  nohup kubectl port-forward service/todoapp 8080:8080  -n todoapp --address="0.0.0.0" > /tmp/kubectl-port-forward.log 2>&1 &
}


_exposeAstroshop(){
  printInfo "Exposing Astroshop in your dev.container"
  nohup kubectl port-forward service/astroshop-frontendproxy 8080:8080  -n astroshop --address="0.0.0.0" > /tmp/kubectl-port-forward.log 2>&1 &
}


installMkdocs(){
  installRunme
  printInfo "Installing Mkdocs"
  pip install --break-system-packages -r docs/requirements/requirements-mkdocs.txt
}


exposeMkdocs(){
  printInfo "Exposing Mkdocs in your dev.container"
  nohup mkdocs serve -a localhost:8000 > /dev/null 2>&1 &
}


_exposeLabguide(){
  printInfo "Exposing Lab Guide in your dev.container"
  cd $CODESPACE_VSCODE_FOLDER/lab-guide/
  nohup node bin/server.js --host 0.0.0.0 --port 3000 > /dev/null 2>&1 &
  cd -
}

_buildLabGuide(){
  printInfoSection "Building the Lab-guide in port 3000"
  cd $CODESPACE_VSCODE_FOLDER/lab-guide/
  node bin/generator.js
  cd -
}

deployAstronomyShop() {

  # deploy astronomy shop
  NAME=$(whoami)-k8s-otel-o11y

  sed -i "s,NAME_TO_REPLACE,$NAME," cluster-manifests/astronomy-shop/default-values.yaml

  helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts

  kubectl create namespace astronomy-shop

  helm install astronomy-shop open-telemetry/opentelemetry-demo --values $CODESPACE_VSCODE_FOLDER/cluster-manifests/astronomy-shop/default-values.yaml --namespace astronomy-shop --version "0.31.0"

}

deployOpenTelemetryCapstone() {
  
  printInfoSection "Deploy OpenTelemetry Capstone"

  ### Preflight Check

  # Check if DT_ENDPOINT is set
  if [ -z "$DT_ENDPOINT" ]; then
    printInfo "Error: DT_ENDPOINT is not set."
    exit 1
  fi

  # Check if DT_API_TOKEN is set
  if [ -z "$DT_API_TOKEN" ]; then
    printInfo "Error: DT_API_TOKEN is not set."
    exit 1
  fi

  # Check if NAME is set
  if [ -z "$NAME" ]; then
    printInfo "Error: NAME is not set."
    exit 1
  fi

  export CAPSTONE_DIR=$CODESPACE_VSCODE_FOLDER/lab-modules/opentelemetry-capstone

  printInfo "All required variables are set."

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
  kubectl apply -f $CAPSTONE_DIR/opentelemetry/cert-manager.yaml

  # Wait for ready pods
  waitForAllReadyPods cert-manager

  # Substitute for waitForAllReadyPods
  # Run the kubectl wait command and capture the exit status
  #kubectl -n cert-manager wait pod --selector=app.kubernetes.io/instance=cert-manager --for=condition=ready --timeout=300s
  #status=$?

  # Check the exit status
  #if [ $status -ne 0 ]; then
  #  echo "Error: Pods did not become ready within the timeout period."
  #  exit 1
  #else
  #  echo "Pods are ready."
  #fi

  # Deploy opentelemetry-operator
  kubectl apply -f $CAPSTONE_DIR/opentelemetry/opentelemetry-operator.yaml

  # Wait for ready pods
  waitForAllReadyPods opentelemetry-operator-system

  # Substitute for waitForAllReadyPods
  # Run the kubectl wait command and capture the exit status
  #kubectl -n opentelemetry-operator-system wait pod --selector=app.kubernetes.io/name=opentelemetry-operator --for=condition=ready --timeout=300s
  #status=$?

  # Check the exit status
  #if [ $status -ne 0 ]; then
  #  echo "Error: Pods did not become ready within the timeout period."
  #  exit 1
  #else
  #  echo "Pods are ready."
  #fi

  ### OpenTelemetry Collectors

  # Create clusterrole with read access to Kubernetes objects
  kubectl apply -f $CAPSTONE_DIR/opentelemetry/rbac/otel-collector-k8s-clusterrole.yaml

  # Create clusterrolebinding for OpenTelemetry Collector service accounts
  kubectl apply -f $CAPSTONE_DIR/opentelemetry/rbac/otel-collector-k8s-clusterrole-crb.yaml

  # OpenTelemetry Collector - Dynatrace Distro (Deployment)
  kubectl apply -f $CAPSTONE_DIR/opentelemetry/collector/dynatrace/otel-collector-dynatrace-deployment-crd.yaml

  # OpenTelemetry Collector - Dynatrace Distro (Daemonset)
  kubectl apply -f $CAPSTONE_DIR/opentelemetry/collector/dynatrace/otel-collector-dynatrace-daemonset-crd.yaml

  # OpenTelemetry Collector - Contrib Distro (Deployment)
  kubectl apply -f $CAPSTONE_DIR/opentelemetry/collector/contrib/otel-collector-contrib-deployment-crd.yaml

  # OpenTelemetry Collector - Contrib Distro (Daemonset)
  kubectl apply -f $CAPSTONE_DIR/opentelemetry/collector/contrib/otel-collector-contrib-daemonset-crd.yaml

  # Wait for ready pods
  waitForAllReadyPods dynatrace

  # Run the kubectl wait command and capture the exit status
  #kubectl -n dynatrace wait pod --selector=app.kubernetes.io/component=opentelemetry-collector --for=condition=ready --timeout=300s
  #status=$?

  # Check the exit status
  #if [ $status -ne 0 ]; then
  #  echo "Error: Pods did not become ready within the timeout period."
  #  exit 1
  #else
  #  echo "Pods are ready."
  #fi

  ### Astronomy Shop

  # Customize astronomy-shop helm values
  sed -i "s,NAME_TO_REPLACE,$NAME," $CAPSTONE_DIR/astronomy-shop/collector-values.yaml

  # Update astronomy-shop OpenTelemetry Collector export endpoint via helm
  helm upgrade astronomy-shop open-telemetry/opentelemetry-demo --values $CAPSTONE_DIR/astronomy-shop/collector-values.yaml --namespace astronomy-shop --version "0.31.0"

  # Wait for ready pods
  waitForAllReadyPods astronomy-shop

  # Substitute for waitForAllReadyPods
  # Run the kubectl wait command and capture the exit status
  #kubectl -n astronomy-shop wait pod --selector=app.kubernetes.io/instance=astronomy-shop --for=condition=ready --timeout=300s
  #status=$?

  # Check the exit status
  #if [ $status -ne 0 ]; then
  #  echo "Error: Pods did not become ready within the timeout period."
  #  exit 1
  #else
  #  echo "Pods are ready."
  #fi

  # Expose Astronomy Shop after redeployment
  exposeAstronomyShop

  # Complete
  printInfoSection "Capstone deployment complete!"
}

exposeAstronomyShop() {
  printInfoSection "Exposing Astronomy Shop via NodePort 30100"

  printInfo "Change astroshop-frontendproxy service from LoadBalancer to NodePort"
  kubectl patch service astronomy-shop-frontendproxy --namespace=astronomy-shop  --patch='{"spec": {"type": "NodePort"}}'

  printInfo "Define the NodePort to expose the app from the Cluster"
  kubectl patch service astronomy-shop-frontendproxy --namespace=astronomy-shop --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":30100}]'

}

_deployAstroshop(){
  printInfoSection "Deploying Astroshop"

  # read the credentials and variables
  #saveReadCredentials 

  # To override the Dynatrace values call the function with the following order
  #saveReadCredentials $DT_TENANT $DT_OPERATOR_TOKEN $DT_INGEST_TOKEN $DT_INGEST_TOKEN $DT_OTEL_ENDPOINT

  ###
  # Instructions to install Astroshop with Helm Chart from R&D and images built in shinojos repo (including code modifications from R&D)
  ####
  #sed -i 's~domain.placeholder~'"$DOMAIN"'~' $CODESPACE_VSCODE_FOLDER/.devcontainer/astroshop/helm/dt-otel-demo-helm/values.yaml
  #sed -i 's~domain.placeholder~'"$DOMAIN"'~' $CODESPACE_VSCODE_FOLDER/.devcontainer/astroshop/helm/dt-otel-demo-helm-deployments/values.yaml

  helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts

  helm dependency build $CODESPACE_VSCODE_FOLDER/.devcontainer/astroshop/helm/dt-otel-demo-helm

  kubectl create namespace astroshop

  DT_OTEL_ENDPOINT=$DT_TENANT/api/v2/otlp

  printInfo "OTEL Configuration URL $DT_OTEL_ENDPOINT and Ingest Token $DT_INGEST_TOKEN"  

  helm upgrade --install astroshop -f $CODESPACE_VSCODE_FOLDER/.devcontainer/astroshop/helm/dt-otel-demo-helm-deployments/values.yaml --set default.image.repository=docker.io/shinojosa/astroshop --set default.image.tag=1.12.0 --set collector_tenant_endpoint=$DT_OTEL_ENDPOINT --set collector_tenant_token=$DT_INGEST_TOKEN -n astroshop $CODESPACE_VSCODE_FOLDER/.devcontainer/astroshop/helm/dt-otel-demo-helm

  printInfo "Stopping all cronjobs from Demo Live since they are not needed with this scenario"

  kubectl get cronjobs -n astroshop -o json | jq -r '.items[] | .metadata.name' | xargs -I {} kubectl patch cronjob {} -n astroshop --patch '{"spec": {"suspend": true}}'

  # Listing all cronjobs
  kubectl get cronjobs -n astroshop

  waitForAllPods astroshop

  printInfo "Astroshop deployed succesfully"
}

deleteCodespace(){
  printWarn "Warning! Codespace $CODESPACE_NAME will be deleted, the connection will be lost in a sec... " 
  gh codespace delete --codespace "$CODESPACE_NAME" --force
}


showOpenPorts(){
  sudo netstat -tulnp
  # another alternative is 
  # sudo ss -tulnp
}

deployGhdocs(){
  mkdocs gh-deploy
}