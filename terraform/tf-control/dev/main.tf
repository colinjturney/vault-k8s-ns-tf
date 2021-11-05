# Create K8s Service Accounts

module "tf-k8s" {
    source = "../../modules/tf-k8s"

    k8s_sa_name_colin_app = var.k8s_sa_name_colin_app
    k8s_sa_name_lewis_app = var.k8s_sa_name_lewis_app
    k8s_namespace = var.k8s_namespace
}

# Create Customer Success LOB - we have a K8s cluster per LOB in this scenario.
# There are some LOB secrets that need to be accessed by lower-level OUs here, 
# as well as within those lower-level OU namespaces themselves

module "cs-vault-lob" {
    source = "../../modules/tf-vault-lob"

    providers = {
        vault.root  = vault.root
        vault.lob   = vault.customer-success
    }

    lob_name = var.lob_customer_success
    lob_group_member_ids = [module.cs-csa-vault-team.vault-team-group-id]

    k8s_host    = var.k8s_host
    k8s_issuer  = var.k8s_issuer

    vault_server_sa_secret_name = module.tf-k8s.vault-server-auth-secret-name
}

module "cs-csa-vault-team" {
    source = "../../modules/tf-vault-team" 
    providers = {
        vault.lob   = vault.customer-success
        vault.team  = vault.csa
    }

    lob_name = var.lob_customer_success
    team_name = var.team_csa
    team_group_member_ids = [module.cs-csa-colin-vault-app.app-entity-id,module.cs-csa-lewis-vault-app.app-entity-id]

}

module "cs-csa-colin-vault-app" {
    source = "../../modules/tf-vault-app"
    providers = {
        vault.lob    = vault.customer-success
        vault.team   = vault.csa
    }

    app_name = var.app_name_colinapp
    lob_name = var.lob_customer_success
    
    team_name = var.team_csa
    team_secret_mount_accessor_id = module.cs-csa-vault-team.vault-team-secret-mount-accessor

    kubernetes_auth_backend_path = module.cs-vault-lob.vault-lob-k8s-auth-backend-path
    kubernetes_auth_backend_mount_accessor = module.cs-vault-lob.vault-lob-k8s-auth-backend-mount-accessor

    app_sa_name = var.k8s_sa_name_colin_app
    app_sa_namespace = var.k8s_namespace
    app_sa_uid  = module.tf-k8s.k8s-sa-colinapp-uid
 
}

module "cs-csa-lewis-vault-app" {
    source = "../../modules/tf-vault-app"
    providers = {
        vault.lob    = vault.customer-success
        vault.team   = vault.csa
    }

    app_name = var.app_name_lewisapp
    lob_name = var.lob_customer_success
    
    team_name = var.team_csa
    team_secret_mount_accessor_id = module.cs-csa-vault-team.vault-team-secret-mount-accessor

    kubernetes_auth_backend_path = module.cs-vault-lob.vault-lob-k8s-auth-backend-path
    kubernetes_auth_backend_mount_accessor = module.cs-vault-lob.vault-lob-k8s-auth-backend-mount-accessor

    app_sa_name = var.k8s_sa_name_lewis_app
    app_sa_namespace = var.k8s_namespace
    app_sa_uid  = module.tf-k8s.k8s-sa-lewisapp-uid
 
}