resource "authentik_policy_reputation" "minimum_username_reputation" {
  name = "minimum_username_reputation"
  execution_logging = true
  threshold = -10
  check_ip = false
  check_username = true
}

resource "authentik_policy_reputation" "minimum_ip_reputation" {
  name = "minimum_ip_reputation"
  execution_logging = true
  threshold = -10
  check_ip = true
  check_username = false
}

resource "authentik_policy_expression" "account_enabled" {
  name       = "account_enabled"
  expression = "return request.user.is_active"
}
