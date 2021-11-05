output "vault-lob-namespace-id" {
    value = vault_namespace.ns-lob.id
}

output "vault-lob-k8s-auth-backend-path" {
    value = vault_auth_backend.k8s-lob.path
}

output "vault-lob-k8s-auth-backend-mount-accessor" {
    value = vault_auth_backend.k8s-lob.accessor
}

output "vault-lob-group-id" {
    value = vault_identity_group.group-lob.id
}