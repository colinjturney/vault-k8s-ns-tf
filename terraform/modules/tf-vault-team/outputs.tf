output "vault-team-namespace-id" {
    value = vault_namespace.ns-team.id
}

output "vault-team-group-id" {
    value = vault_identity_group.group-team.id
}

output "vault-team-secret-mount-accessor" {
    value = vault_mount.team-secret-mount.accessor
}