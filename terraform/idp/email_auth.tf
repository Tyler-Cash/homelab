resource "authentik_stage_user_write" "write_user" {
  name = "write_user"
  create_users_group = authentik_group.jellyfin.id
}

resource "authentik_stage_email" "email_confirmation" {
  from_address = var.authentik_from_address
  name = "email-verification"
  subject = "Account Confirmation"
  template = "email/account_confirmation.html"
  activate_user_on_success = true
}

resource "authentik_stage_invitation" "invite_link" {
  name = "invite_link"
  continue_flow_without_invitation = false
}

resource "authentik_stage_prompt_field" "username" {
  field_key = "username"
  name = "username"
  label = "Username"
  type = "username"
}

resource "authentik_stage_prompt_field" "password" {
  field_key = "password"
  name = "password"
  label = "Password"
  type = "password"
}

resource "authentik_stage_prompt_field" "email" {
  field_key = "email"
  name = "email"
  label = "Email"
  type = "email"
}

resource "authentik_stage_prompt_field" "name" {
  field_key = "name"
  name = "name"
  label = "Name"
  type = "text"
}

data "authentik_stage" "auto_login" {
  name = "default-source-enrollment-login"
}

resource "authentik_policy_password" "password_length" {
  name          = "password is minimum length"
  length_min    = 8
  error_message = "Password must be at least 8 characters long"
}
resource "authentik_policy_password" "password_hibp" {
  name          = "Have I been pwned check"
  check_have_i_been_pwned = true
  hibp_allowed_count    = 0
  error_message = "Password is in public list of compromised passwords"
}

resource "authentik_stage_prompt" "user_information" {
  name = "user_information"
  fields = [
    authentik_stage_prompt_field.name.id,
    authentik_stage_prompt_field.email.id,
    authentik_stage_prompt_field.username.id,
    authentik_stage_prompt_field.password.id,
  ]

  validation_policies = [
    authentik_policy_password.password_length.id,
    authentik_policy_password.password_hibp.id
  ]
}

resource "authentik_flow_stage_binding" "invite_link_binding" {
  target = authentik_flow.email_enrollment.uuid
  stage = authentik_stage_invitation.invite_link.id
  order = 10
  policy_engine_mode = "all"
}

resource "authentik_flow_stage_binding" "user_information_binding" {
  target = authentik_flow.email_enrollment.uuid
  stage = authentik_stage_prompt.user_information.id
  order = authentik_flow_stage_binding.invite_link_binding.order + 1
  policy_engine_mode = "all"
}

resource "authentik_flow_stage_binding" "create_user_binding" {
  target = authentik_flow.email_enrollment.uuid
  stage = authentik_stage_user_write.write_user.id
  order = authentik_flow_stage_binding.user_information_binding.order + 1
  policy_engine_mode = "all"
}
resource "authentik_flow_stage_binding" "verify_email_binding" {
  target = authentik_flow.email_enrollment.uuid
  stage = authentik_stage_email.email_confirmation.id
  order = authentik_flow_stage_binding.create_user_binding.order + 1
  policy_engine_mode = "all"
}

resource "authentik_flow_stage_binding" "login_binding" {
  target = authentik_flow.email_enrollment.uuid
  stage = data.authentik_stage.auto_login.id
  order = authentik_flow_stage_binding.verify_email_binding.order + 1
  policy_engine_mode = "all"
}


resource "authentik_flow" "email_enrollment" {
  name        = "email-enrollment"
  title       = "Email Enrollment"
  slug        = "email-enrollment"
  designation = "enrollment"
  policy_engine_mode = "all"
  layout = "stacked"
}
