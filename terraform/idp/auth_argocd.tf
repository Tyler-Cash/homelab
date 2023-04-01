resource "authentik_group" "argocd_admin" {
  name         = "argocd_admin"
  is_superuser = false
}

resource "authentik_group" "argocd" {
  name         = "argocd"
  is_superuser = false
}

resource "authentik_provider_oauth2" "argocd_ouath2" {
  name      = "argocd"
  client_id = "argocd"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  access_code_validity = "minutes=10"
  redirect_uris = [ "https://argocd.k8s.tylercash.dev/auth/callback"]
  signing_key = data.authentik_certificate_key_pair.generated.id
  property_mappings = [
    data.authentik_scope_mapping.openid.id,
    data.authentik_scope_mapping.email.id,
    data.authentik_scope_mapping.profile.id
  ]
}

resource "authentik_application" "argocd_application" {
  name = authentik_provider_oauth2.argocd_ouath2.name
  slug = authentik_provider_oauth2.argocd_ouath2.name
  protocol_provider = authentik_provider_oauth2.argocd_ouath2.id
  meta_icon = "https://cncf-branding.netlify.app/img/projects/argo/icon/white/argo-icon-white.svg"
  meta_launch_url = "https://argocd.k8s.tylercash.dev/applications"
  policy_engine_mode = "all"
}

resource "kubernetes_secret" "argocd-oidc-secrets" {
  metadata {
    name = "argocd-oidc-secrets"
    namespace = "argocd"
    labels = {
      "app.kubernetes.io/part-of": "argocd"
    }
  }

  data = {
    "oidc.authentik.client_id" = authentik_provider_oauth2.argocd_ouath2.client_id
    "oidc.authentik.client_secret" = authentik_provider_oauth2.argocd_ouath2.client_secret
  }
}

resource "authentik_policy_binding" "argocd_stop_brute_force_username" {
  target = authentik_application.argocd_application.uuid
  policy = authentik_policy_reputation.minimum_username_reputation.id
  order  = 0
  negate = true
}
resource "authentik_policy_binding" "argocd_stop_brute_force_ip" {
  target = authentik_application.argocd_application.uuid
  policy = authentik_policy_reputation.minimum_ip_reputation.id
  order  = authentik_policy_binding.argocd_stop_brute_force_username.order + 1
  negate = true
}

resource "authentik_policy_binding" "argocd_is_enabled" {
  target = authentik_application.argocd_application.uuid
  policy = authentik_policy_expression.account_enabled.id
  order  = authentik_policy_binding.argocd_stop_brute_force_ip.order + 1
}
