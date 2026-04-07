id: enablement-kubernetes-opentelemetry-openpipeline

summary: opentelemetry log processing with dynatrace openpipeline

author: Tony Pope-Cruz

# Enablement Kubernetes OpenTelemetry OpenPipeline

[![Integration tests](https://github.com/dynatrace-wwse/enablement-kubernetes-opentelemetry-openpipeline/actions/workflows/integration-tests.yaml/badge.svg)](https://github.com/dynatrace-wwse/enablement-kubernetes-opentelemetry-openpipeline/actions)
[![Version](https://img.shields.io/github/v/release/dynatrace-wwse/enablement-kubernetes-opentelemetry-openpipeline?color=blueviolet)](https://github.com/dynatrace-wwse/enablement-kubernetes-opentelemetry-openpipeline/releases)
[![Commits](https://img.shields.io/github/commits-since/dynatrace-wwse/enablement-kubernetes-opentelemetry-openpipeline/latest?color=ff69b4&include_prereleases)](https://github.com/dynatrace-wwse/enablement-kubernetes-opentelemetry-openpipeline/graphs/commit-activity)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?color=green)](https://github.com/dynatrace-wwse/enablement-kubernetes-opentelemetry-openpipeline/blob/main/LICENSE)
## Lab Overview

During this hands-on training, we’ll learn how to capture logs from Kubernetes using OpenTelemetry and ship them to Dynatrace for analysis.  This will demonstrate how to use Dynatrace with OpenTelemetry; without any Dynatrace native components installed on the Kubernetes cluster (Operator, OneAgent, ActiveGate, etc.).  We'll then utilize Dynatrace OpenPipeline to process OpenTelemetry logs at ingest, to manipulate fields, extract metrics, raise alert events, and manage retention periods, in order to make them easier to analyze and leverage.

**Lab tasks:**

1. Ingest Kubernetes logs using OpenTelemetry Collector
1. Deploy OpenTelemetry Collector for logs, traces, and metrics
1. Create custom Buckets for Grail storage management
1. Process Astronomy Shop logs with Dynatrace OpenPipeline
1. Process Kubernetes Events logs with Dynatrace OpenPipeline
1. Process OpenTelemetry Collector logs with Dynatrace OpenPipeline
1. Query and visualize logs and metrics in Dynatrace using DQL

Ready to learn how to ship Kubernetes logs with OpenTelemetry and process them with Dynatrace OpenPipeline?

## [View the Lab Guide](https://dynatrace-wwse.github.io/enablement-kubernetes-opentelemetry-openpipeline)