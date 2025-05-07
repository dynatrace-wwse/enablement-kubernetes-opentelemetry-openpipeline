#!/bin/bash

#loading functions to script
source /workspaces/$RepositoryName/.devcontainer/util/functions.sh

bindFunctionsInShell

setupAliases

createKindCluster

installK9s

#BeforeGoLive: uncomment this. This is only needed for professors to have the Mkdocs live in the container
#installMkdocs

# Dynatrace Credentials are read and saved as a configmap for ease of use
#dynatraceEvalReadSaveCredentials

# Dynatrace Operator can be deployed automatically
#dynatraceDeployOperator

# You can deploy CNFS or AppOnly
#deployCloudNative
#deployApplicationMonitoring

# In here you deploy the Application you want
# The TODO App will be deployed as a sample
#deployTodoApp

# The Astroshop keeping changes of demo.live needs certmanager
#certmanagerInstall
#certmanagerEnable
#deployAstroshop

# If you want to deploy your own App, just create a function in the functions.sh file and call it here.
deployAstronomyShop

exposeAstronomyShop

# e2e testing
# If the codespace is created (eg. via a Dynatrace workflow)
# and hardcoded to have a name starting with dttest-
# Then run the e2e test harness
# Otherwise, send the startup ping
if [[ "$CODESPACE_NAME" == dttest-* ]]; then
    # Set default repository for gh CLI
    gh repo set-default "$GITHUB_REPOSITORY"

    # Set up a label, used if / when the e2e test fails
    # This may already be set, so catch error and always return true
    gh label create "e2e test failed" --force || true

    # Install required Python packages
    pip install -r "/workspaces/$REPOSITORY_NAME/.devcontainer/testing/requirements.txt" --break-system-packages

    # Run the test harness script
    python "/workspaces/$REPOSITORY_NAME/.devcontainer/testing/testharness.py"

    # Testing finished. Destroy the codespace
    gh codespace delete --codespace "$CODESPACE_NAME" --force
else

    # Your content here
    printInfo "Sending BizEvent to track usage of $RepositoryName"
    #BeforeGoLive: Uncomment, this will post a BizEvent to keep track of instantiations
    postCodespaceTracker $RepositoryName
    
    printInfo "Finished creating devcontainer"
fi