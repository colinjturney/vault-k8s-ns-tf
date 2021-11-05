output "vault-server-auth-secret-name" {
    value = kubernetes_service_account.vault-server-auth.default_secret_name
}

output "k8s-sa-colinapp-uid" {
    value = kubernetes_service_account.vault-agent-auth-colinapp.metadata[0].uid
}

output "k8s-sa-lewisapp-uid" {
    value = kubernetes_service_account.vault-agent-auth-lewisapp.metadata[0].uid
}