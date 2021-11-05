# Create Vault Namespace for each LOB

resource "vault_namespace" "ns-lob" {
    provider = vault.root
    path     = "${var.lob_name}"
}

# Fetch K8s SA data

data "kubernetes_secret" "vault-server-sa" {   
    metadata {
        name = var.vault_server_sa_secret_name
    }
}

# Create K8s Auth Method Backend and Config for each LOB

resource "vault_auth_backend" "k8s-lob" {
    provider    = vault.lob
    type        = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "k8s-config-lob" {
    provider                = vault.lob

    backend                 = vault_auth_backend.k8s-lob.path
    kubernetes_host         = var.k8s_host
    kubernetes_ca_cert      = data.kubernetes_secret.vault-server-sa.data["ca.crt"]
    token_reviewer_jwt      = data.kubernetes_secret.vault-server-sa.data["token"]
    issuer                  = var.k8s_issuer
}

# Create Internal Group for LOB

resource "vault_identity_group" "group-lob" {
    provider = vault.lob

    name = "${var.lob_name}-group"
    type = "internal"

    member_group_ids = var.lob_group_member_ids

    policies = ["${var.lob_name}-secret-policy"]

    metadata = {
        LobName     = var.lob_name,
        Description = "Internal Group for the ${var.lob_name} LOB"
    }
}


# Create some secret on LOB level and some policy enforced on this NS level

resource "vault_mount" "lob-secret-mount" {
    provider = vault.lob

    path        = "secret"
    type        = "kv"
    description = "KV Secrets engine for ${var.lob_name} LOB"
}

resource "vault_generic_secret" "lob-secret" {
    provider = vault.lob    
    path = "secret/${var.lob_name}"

    data_json = <<EOT
{
    "value": "All of ${var.lob_name} should read this"
}
EOT

depends_on = [vault_mount.lob-secret-mount]
}

resource "vault_policy" "lob-secret-policy" {
    provider    = vault.lob    
    name        = "${var.lob_name}-secret-policy"

    policy = <<EOT
path "secret/{{identity.entity.metadata.LobName}}" {
  capabilities = ["read","list"]
}

path "{{identity.entity.metadata.TeamName}}/*" {
  capabilities = ["read","list"]
}

path "sys/capabilities-self" {
    capabilities = ["update"]
}
EOT
}