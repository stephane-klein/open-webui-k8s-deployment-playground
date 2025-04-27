terraform {
    required_providers {
        scaleway = {
            source = "scaleway/scaleway"
            version = "2.53.0" # See last version on this url https://github.com/scaleway/terraform-provider-scaleway/releases
        }
    }
    backend "s3" {
        bucket                      = "openwebux-terraform-poc"
        key                         = "openwebux-terraform-poc"
        region                      = "fr-par"
        skip_credentials_validation = true
        skip_region_validation      = true
        skip_requesting_account_id  = true
        use_path_style              = true
        endpoints = {
            s3 = "https://s3.fr-par.scw.cloud"
        }
    }
}

provider "scaleway" {
    zone   = "fr-par-1"
    region = "fr-par"
}

variable "openwebui_project_id" {
    type    = string
    /* set by TF_VAR_openwebui_project_id variable env */
}

variable "openwebui_postgres_password" {
    type    = string
    /* set by TF_VAR_openwebui_postgres_password variable env */
}

/* public ssh key used in Virtual Instances */
resource "scaleway_account_ssh_key" "stephane-klein-public-ssh-key-dev" {
    name        = "stephane-klein-public-ssh-key"
    project_id  = var.openwebui_project_id
    public_key  = file("${path.module}/ssh-keys/stephane-klein.pub")
}

/* Begin section: create VPC (Private Networks) */

resource "scaleway_vpc" "openwebui_private_network" {
    name   = "openwebui_private_network"
    project_id  = var.openwebui_project_id
}

resource "scaleway_vpc_private_network" "openwebui_private_network" {
    name = "openwebui_private_network"
    project_id  = var.openwebui_project_id
    region = "fr-par"

    vpc_id = scaleway_vpc.openwebui_private_network.id
}

/* End section: create VPC (Private Networks) */


resource "scaleway_k8s_cluster" "cluster" {
    name    = "openwebux-cluster"
    type    = "kapsule"
    project_id  = var.openwebui_project_id

    version = "1.32.3"
    cni     = "cilium"
    private_network_id = scaleway_vpc_private_network.openwebui_private_network.id
    delete_additional_resources = true
}

resource "scaleway_k8s_pool" "pool" {
    cluster_id = scaleway_k8s_cluster.cluster.id
    name       = "pool"
    node_type  = "DEV1-M"
    size       = 1
}

output "kubeconfig" {
    value       = scaleway_k8s_cluster.cluster.kubeconfig[0].config_file
    sensitive   = true
}

/* Begin section: Object Storage sklein-openwebui-poc-data */
resource "scaleway_object_bucket" "sklein_openwebui_poc_data" {
    name = "sklein-openwebui-poc-data"
    project_id  = var.openwebui_project_id
    region = "fr-par"

    versioning {
        enabled = false
    }
}

resource "scaleway_iam_application" "sklein_openwebui_poc_data" {
    name = "sklein_openwebui_poc_data"
}

resource "scaleway_iam_policy" "sklein_openwebui_poc_data_policy" {
    name = "sklein_openwebui_poc_data_policy"
    application_id = scaleway_iam_application.sklein_openwebui_poc_data.id
    rule {
        project_ids = [var.openwebui_project_id]
        permission_set_names = [
            "ObjectStorageFullAccess"
        ]
    }
}

resource "scaleway_iam_api_key" "sklein_openwebui_poc_data" {
    application_id = scaleway_iam_application.sklein_openwebui_poc_data.id
    default_project_id = var.openwebui_project_id
}

output "sklein_openwebui_poc_data_api_access_key" {
    value = scaleway_iam_api_key.sklein_openwebui_poc_data.access_key
}

output "sklein_openwebui_poc_data_api_secret_key" {
    value = scaleway_iam_api_key.sklein_openwebui_poc_data.secret_key
    sensitive = true
}

resource "local_file" "helm_values" {
  content = templatefile("values.yaml.tpl", {
    s3_access_key   = scaleway_iam_api_key.sklein_openwebui_poc_data.access_key
    s3_secret_key   = scaleway_iam_api_key.sklein_openwebui_poc_data.secret_key
    s3_endpoint_url = scaleway_object_bucket.sklein_openwebui_poc_data.endpoint
    s3_region       = scaleway_object_bucket.sklein_openwebui_poc_data.region
    s3_bucket       = split("/", scaleway_object_bucket.sklein_openwebui_poc_data.id)[1]
    s3_key_prefix   = "openwebui"

    openwebui_postgres_password = var.openwebui_postgres_password
  })
  filename = "values.yaml"
}

/* End section: Object Storage sklein-openwebui-poc-data */
