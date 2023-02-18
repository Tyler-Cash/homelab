resource "authentik_group" "jellyfin_admin" {
  name         = "jellyfin_admin"
  is_superuser = false
}

resource "authentik_group" "jellyfin" {
  name         = "jellyfin"
  is_superuser = false
}

resource "authentik_provider_ldap" "jellyfin_ldap" {
  name      = "jellyfin"
  base_dn   = "dc=ldap,dc=tylercash,dc=dev"
  bind_flow = data.authentik_flow.default-authentication-flow.id
  search_group = authentik_group.bind.id
}

resource "authentik_application" "jellyfin_application" {
  name              = authentik_provider_ldap.jellyfin_ldap.name
  slug              = authentik_provider_ldap.jellyfin_ldap.name
  protocol_provider = authentik_provider_ldap.jellyfin_ldap.id
  meta_icon = "https://developer.asustor.com/uploadIcons/0020_999_1568614457_Jellyfin_256.png"
  meta_launch_url = "https://jellyfin.k8s.tylercash.dev"
  policy_engine_mode = "all"
}

resource "authentik_outpost" "jellyfin_outpost" {
  name = "jellyfin-outpost"
  type = "ldap"
  protocol_providers = [
    authentik_provider_ldap.jellyfin_ldap.id
  ]
}