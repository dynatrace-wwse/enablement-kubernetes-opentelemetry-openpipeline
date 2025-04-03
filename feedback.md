# Some quick feedback
- no  need to clone the repo
- no need to set the $base_dir, specially since the variable CODESPACE_VSCODE_FOLDER contains exactly that path CODESPACE_VSCODE_FOLDER=/workspaces/enablement-kubernetes-opentelemetry-openpipeline
- the lab guide  generation and exposure can be automated withing the codespace creation, with this setup with onliner they can do that:

```bash
cd lab-guide && node bin/generator.js && nohup node bin/server.js > /dev/null 2>&1 &
```

- no need to clone the repo, the exposure and generation can be done inside the codespace.
- in the installation, the $base_dir is in another readme (the beginning) not the one from the labguide, so  I personally would put them all together or make the prep easier for the student to focus more on the training at hand.

- creation of certmanater can be automated. kubectl apply -f cluster-manifests/cert-manager.yaml

- in the default.values.yaml (which is used for the helm chart) I find weird that this configuration is automated:
```yaml
 - name: OTEL_RESOURCE_ATTRIBUTES
      value: 'service.name=$(OTEL_SERVICE_NAME),service.namespace=vscode-k8s-otel-o11y,service.version={{ .Chart.AppVersion }}'

```

with the name 'vscode-k8s-otel-o11y' where no namespace with that name exists. Can be eliminated or hardcoded if works as expected.

