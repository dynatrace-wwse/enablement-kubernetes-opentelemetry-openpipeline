#!/bin/bash
# Load framework
source .devcontainer/util/source_framework.sh

printInfoSection "Running integration Tests for $RepositoryName"

assertRunningPod astronomy-shop astronomy-shop-adservice

assertRunningPod astronomy-shop astronomy-shop-frontendproxy

assertRunningApp astroshop
