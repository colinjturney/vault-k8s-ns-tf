variable "k8s_host" {
    type = string
}

variable "k8s_issuer" {
    type = string
}

variable "vault_server_sa_secret_name" {
    type = string
}

variable "lob_name" {
    type = string
}

variable "lob_group_member_ids" {
    type = list
}