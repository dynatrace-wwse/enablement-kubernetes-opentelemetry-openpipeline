#!/bin/bash
export SECONDS=0
source .devcontainer/util/source_framework.sh

setUpTerminal

startKindCluster

installK9s

deployAstronomyShop

exposeAstronomyShop

# which other functions?

finalizePostCreation

printInfoSection "Your dev container finished creating"