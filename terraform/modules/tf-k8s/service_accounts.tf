# Create Vault Server Auth Service Account

resource "kubernetes_service_account" "vault-server-auth" {
    metadata {
        name        = "vault-server-auth"
        namespace   = "default"
    }
}

resource "kubernetes_cluster_role_binding" "vault-server-auth" {
    
    metadata {
        name        = "rb-vault-server-auth"
    }

    role_ref {
        api_group   = "rbac.authorization.k8s.io"
        kind        = "ClusterRole"
        name        = "system:auth-delegator"
    }

    subject {
        kind        = "ServiceAccount"
        name        = "vault-server-auth"
        namespace   = var.k8s_namespace
    }
}

# Create Vault Agent Auth Service Account

resource "kubernetes_service_account" "vault-agent-auth-colinapp" {
    metadata {
        name        = var.k8s_sa_name_colin_app
        namespace   = var.k8s_namespace
    }
}

resource "kubernetes_service_account" "vault-agent-auth-lewisapp" {
    metadata {
        name        = var.k8s_sa_name_lewis_app
        namespace   = var.k8s_namespace
    }
}