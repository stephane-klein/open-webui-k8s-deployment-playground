# Open WebUI Kubernetes deployment playground

Note about this project in french: https://notes.sklein.xyz/Projet%2029/

This folder contains a deployment script for installing [Open WebUI](https://github.com/open-webui/open-webui) on Kubernetes. The deployment connects Open WebUI to [Scaleway Generative APIs](https://www.scaleway.com/en/generative-apis/) and utilizes [Open WebUI Helm Charts](https://github.com/open-webui/helm-charts) for orchestration.

## Préparation

Install [Mise](https://mise.jdx.dev/)

```sh
$ cp .secret.skel .secret
```

## Getting started

```sh
$ mise install
```

If needed, you can force the environment variables loading with this command:

```sh
$ source .envrc
```

Create Object Storage bucket to store Terraform states:

```sh
$ scw object bucket create openwebux-terraform-poc
```

Initialize terraform:

```sh
$ terraform init --upgrade
```

```sh
$ terraform apply
...
```

Check *kubectl* access:

```sh
$ kubectl get nodes
NAME                                             STATUS   ROLES    AGE   VERSION
scw-openwebux-cluster-pool-3555709a26084e07b77   Ready    <none>   81m   v1.32.3
```

```sh
$ helm repo add open-webui https://helm.openwebui.com/
```

```sh
$ helm search repo open-webui -l
NAME                    CHART VERSION   APP VERSION     DESCRIPTION
open-webui/open-webui   6.4.0           0.6.5           Open WebUI: A User-Friendly Web Interface for C...
open-webui/open-webui   6.3.0           0.6.4           Open WebUI: A User-Friendly Web Interface for C...
open-webui/open-webui   6.2.0           0.6.4           Open WebUI: A User-Friendly Web Interface for C...
open-webui/open-webui   6.1.0           0.6.1           Open WebUI: A User-Friendly Web Interface for C...
open-webui/open-webui   6.0.0           0.6.0           Open WebUI: A User-Friendly Web Interface for C...
...
```

Here's how to generate all installation manifests in `./manifests/` for analysis purpose before installation:

```sh
$ helm template -f values.yaml poc-openwebui open-webui/open-webui --version 6.4.0 --output-dir ./manifests
```

Perform the actual installation:

```sh
$ helm install -f values.yaml poc-openwebui open-webui/open-webui --version 6.4.0
```

Uninstallation:

```sh
$ helm uninstall poc-openwebui
```

## Helper scripts

Check if Scaleway Generative API access works correctly:

```sh
$ ./scripts/check-generative-api-access.sh
```
