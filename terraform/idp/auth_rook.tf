resource "authentik_group" "rook" {
  name         = "rook"
  is_superuser = false
}

resource "authentik_provider_saml" "rook_saml" {
  name = "rook"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  acs_url = "https://ceph.k8s.tylercash.dev/auth/saml2"
  property_mappings = [
    data.authentik_property_mapping_saml.username.id,
    data.authentik_property_mapping_saml.name.id,
    data.authentik_property_mapping_saml.groups.id,
    data.authentik_property_mapping_saml.upn.id,
    data.authentik_property_mapping_saml.email.id
  ]
}

resource "authentik_application" "rook_application" {
  name = authentik_provider_saml.rook_saml.name
  slug = authentik_provider_saml.rook_saml.name
  protocol_provider = authentik_provider_saml.rook_saml.id
  meta_icon = "https://cncf-branding.netlify.app/img/projects/rook/icon/color/rook-icon-color.svg"
  meta_launch_url = "https://ceph.k8s.tylercash.dev/"
  policy_engine_mode = "all"
}

