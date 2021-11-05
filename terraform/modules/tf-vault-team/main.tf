# Create a namespace for this team

resource "vault_namespace" "ns-team" {
    provider = vault.lob
    path = "${var.team_name}"
}

resource "vault_identity_group" "group-team" {
    provider = vault.team

    name = "${var.team_name}-group"
    type = "internal"

    member_entity_ids = var.team_group_member_ids

    policies = []

    metadata = {
        TeamName    = var.team_name,
        Description = "Internal Group for the ${var.team_name} team"
    }
}

# Create some secret on Team level and some policy enforced on this NS level

resource "vault_mount" "team-secret-mount" {
    provider = vault.team

    path        = "secret"
    type        = "kv"
    description = "KV Secrets engine for ${var.team_name} Team"
}

resource "vault_generic_secret" "team-secret" {
    provider = vault.team    
    path = "secret/${var.team_name}-team-secret"

    data_json = <<EOT
{
    "value": "All of ${var.team_name} team should read this"
}
EOT

depends_on = [vault_mount.team-secret-mount]
}

resource "vault_policy" "team-secret-policy" {
    provider    = vault.team    
    name        = "${var.team_name}-secret-policy"

    policy = <<EOT
path "secret/{{identity.groups.names.${var.team_name}-group.metadata.TeamName}}-team-secret" {
  capabilities = ["read","list"]
}
EOT
}