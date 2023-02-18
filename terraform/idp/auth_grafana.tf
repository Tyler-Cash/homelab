resource "authentik_group" "grafana_admin" {
  name         = "grafana_admin"
  is_superuser = false
}

resource "authentik_group" "grafana" {
  name         = "grafana"
  is_superuser = false
}

resource "authentik_provider_oauth2" "grafana_ouath2" {
  name      = "grafana"
  client_id = "grafana"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  access_code_validity = "minutes=10"
  redirect_uris = [ "https://grafana.k8s.tylercash.dev/login/generic_oauth"]
  signing_key = data.authentik_certificate_key_pair.generated.id
  property_mappings = [
    data.authentik_scope_mapping.openid.id,
    data.authentik_scope_mapping.email.id,
    data.authentik_scope_mapping.profile.id
  ]
}

resource "authentik_application" "grafana_application" {
  name = authentik_provider_oauth2.grafana_ouath2.name
  slug = authentik_provider_oauth2.grafana_ouath2.name
  protocol_provider = authentik_provider_oauth2.grafana_ouath2.id
  meta_icon = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Grafana_logo.svg/768px-Grafana_logo.svg.png"
  meta_launch_url = "https://grafana.k8s.tylercash.dev"
  policy_engine_mode = "all"
}

resource "kubernetes_secret" "grafana-oidc-secrets" {
  metadata {
    name = "grafana-oidc-secrets"
    namespace = "monitoring"
  }

  data = {
    "client_id" = authentik_provider_oauth2.grafana_ouath2.client_id
    "client_secret" = authentik_provider_oauth2.grafana_ouath2.client_secret
  }
}
