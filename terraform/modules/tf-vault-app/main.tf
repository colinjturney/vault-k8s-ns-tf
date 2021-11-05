
resource "vault_kubernetes_auth_backend_role" "app" {
# Apply this to the cs namespace only, not the app namespace, since it's a shared k8s auth role.
    provider = vault.lob

    backend                             = var.kubernetes_auth_backend_path
    role_name                           = "${var.app_name}-role"
    bound_service_account_names         = [var.app_sa_name]
    bound_service_account_namespaces    = [var.app_sa_namespace]
    token_policies                      = ["${var.lob_name}-secret-policy"]
    token_ttl                           = 3600
    
}

# Create Vault Entity for this App. Entity created on the LOB-level

resource "vault_identity_entity" "app" {
    provider    = vault.lob
    
    name        = var.app_name
    external_policies = true

    metadata    = {
        AppName = var.app_name,
        LobName = var.lob_name
        TeamName = var.team_name
        Environment = "dev"
    }
}

# Create Vault Entity Alias for this App's K8s SA ID

resource "vault_identity_entity_alias" "app" {
    provider    = vault.lob

    name            = var.app_sa_uid
    mount_accessor  = var.kubernetes_auth_backend_mount_accessor
    canonical_id    = vault_identity_entity.app.id
}

resource "vault_generic_secret" "app-secret" {
    provider = vault.team    
    path = "secret/${var.team_name}-app-secrets/${var.app_name}"

    data_json = <<EOT
{
    "value": "Only the ${var.app_name} app should see this"
}
EOT

    depends_on = [var.team_secret_mount_accessor_id]
}

resource "vault_policy" "app-secret-policy" {
    provider    = vault.team    
    name        = "${var.team_name}-app-secret-policy"

    policy = <<EOT
path "secret/{{identity.entity.metadata.TeamName}}-app-secrets/{{identity.entity.metadata.AppName}}" {
  capabilities = ["read","list"]
}
EOT
}

resource "vault_identity_entity_policies" "app-secret-policies" {
    provider = vault.lob
    policies = ["${var.team_name}-team-app-secret-policy"]

    exclusive = false
    entity_id = vault_identity_entity.app.id
}