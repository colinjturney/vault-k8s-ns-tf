terraform {
  required_providers {
    vault = {
      configuration_aliases = [vault.lob, vault.team]
    }
  }
}