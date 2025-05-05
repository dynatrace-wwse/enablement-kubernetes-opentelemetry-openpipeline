--8<-- "snippets/send-bizevent/getting-started.js"
--8<-- "snippets/grail-requirements.md"

## Prerequisites

* Identify Dynatrace OTLP Endpoint
* Generate Dynatrace Access Token
* Identify Your Initials

### Identify Dynatrace OTLP Endpoint

The OpenTelemetry Protocol (OTLP) is the principal network protocol for the exchange of telemetry data between OpenTelemetry-backed services and applications.  The Dynatrace SaaS tenant provides an OTLP endpoint.

[See Related Export with OTLP Documentation](https://docs.dynatrace.com/docs/shortlink/otel-getstarted-otlpexport#export-to-saas-and-activegate)

Identify and save/store your OTLP endpoint for the Dynatrace SaaS tenant:

!!! tip "No Trailing Slash"
    Do not include a trailing slash!

| Type        | URL Pattern                                                               |
|-------------|---------------------------------------------------------------------------|
| Live (Prod) | https://{your-environment-id}.live.dynatrace.com/api/v2/otlp              |
| Stage       | https://{your-environment-id}.sprint.dynatracelabs.com/api/v2/otlp        |
| ActiveGate  | https://{your-activegate-domain}:9999/e/{your-environment-id}/api/v2/otlp |

### Generate Dynatrace Access Token

Generate a new API access token with the following scopes:
```
Ingest events
Ingest logs
Ingest metrics
Ingest OpenTelemetry traces
```
[See Related Dynatrace API Token Creation Documentation](https://docs.dynatrace.com/docs/dynatrace-api/basics/dynatrace-api-authentication#create-token)

![dt access token](../img/prereq-dt_access_token.png)

### Identify Your Initials

In this lab, we'll uniquely identify your OpenTelemetry data using your initials; in case you are using a shared tenant.  We'll be using `<INITIALS>-k8s-otel-o11y` as our pattern.  Identify your initials (3-5 characters) and use them whenever prompted during the lab.

## Continue

<div class="grid cards" markdown>
- [Continue to Codespaces Setup:octicons-arrow-right-24:](3-codespaces.md)
</div>
