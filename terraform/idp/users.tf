
locals {
  service_accounts = {
    "jellyfin" = {active = true, groups = [authentik_group.jellyfin.id, authentik_group.bind.id]}, 
    "test_user" = {active = false, groups = []}
  }
}

resource "authentik_user" "service_account" {
    for_each = local.service_accounts

    username = each.key
    name = each.key
    groups = each.value.groups
    is_active = each.value.active
    path = "service_accounts"
}