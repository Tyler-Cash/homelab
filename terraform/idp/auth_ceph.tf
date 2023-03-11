resource "authentik_group" "ceph" {
  name         = "ceph"
  is_superuser = false
}

resource "authentik_provider_saml" "ceph_saml" {
  name = "ceph"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  acs_url = "https://ceph.k8s.tylercash.dev/auth/saml2"
  signature_algorithm = "http://www.w3.org/2000/09/xmldsig#rsa-sha1"
  digest_algorithm = "http://www.w3.org/2000/09/xmldsig#sha1"
  sp_binding = "post"
  signing_kp = data.authentik_certificate_key_pair.generated.id
  property_mappings = [
    data.authentik_property_mapping_saml.username.id,
    data.authentik_property_mapping_saml.name.id,
    data.authentik_property_mapping_saml.groups.id,
    data.authentik_property_mapping_saml.upn.id,
    data.authentik_property_mapping_saml.email.id
  ]
}

resource "authentik_application" "ceph_application" {
  name = authentik_provider_saml.ceph_saml.name
  slug = authentik_provider_saml.ceph_saml.name
  protocol_provider = authentik_provider_saml.ceph_saml.id
  meta_icon = "https://cncf-branding.netlify.app/img/projects/rook/icon/color/rook-icon-color.svg"
  meta_launch_url = "https://ceph.k8s.tylercash.dev/"
  policy_engine_mode = "all"
}

