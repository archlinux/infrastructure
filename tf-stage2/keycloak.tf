terraform {
  backend "pg" {
    schema_name = "terraform_remote_state_stage2"
  }
}

data "external" "keycloak_admin_user" {
  program = ["${path.module}/../misc/get_key.py", "group_vars/all/vault_keycloak.yml", "vault_keycloak_admin_user", "json"]
}

data "external" "keycloak_admin_password" {
  program = ["${path.module}/../misc/get_key.py", "group_vars/all/vault_keycloak.yml", "vault_keycloak_admin_password", "json"]
}

data "external" "keycloak_smtp_user" {
  program = ["${path.module}/../misc/get_key.py", "group_vars/all/vault_keycloak.yml", "vault_keycloak_smtp_user", "json"]
}

data "external" "keycloak_smtp_password" {
  program = ["${path.module}/../misc/get_key.py", "group_vars/all/vault_keycloak.yml", "vault_keycloak_smtp_password", "json"]
}

data "external" "google_recaptcha_site_key" {
  program = ["${path.module}/../misc/get_key.py", "group_vars/all/vault_google.yml", "vault_google_recaptcha_site_key", "json"]
}

data "external" "google_recaptcha_secret_key" {
  program = ["${path.module}/../misc/get_key.py", "group_vars/all/vault_google.yml", "vault_google_recaptcha_secret_key", "json"]
}

provider "keycloak" {
  client_id = "admin-cli"
  username = data.external.keycloak_admin_user.result.vault_keycloak_admin_user
  password = data.external.keycloak_admin_password.result.vault_keycloak_admin_password
  url = "https://accounts.archlinux.org"
}

variable "gitlab_instance" {
  default = {
    root_url = "https://gitlab.archlinux.org"
    saml_redirect_url = "https://gitlab.archlinux.org/users/auth/saml/callback"
  }
}

resource "keycloak_realm" "archlinux" {
  realm = "archlinux"
  enabled = true
  remember_me = true
  display_name = "Arch Linux"

  reset_password_allowed = true
  verify_email = true
  login_with_email_allowed = true
  password_policy = "length(8) and notUsername"

  browser_flow = "Arch Browser"
  registration_flow = "Arch Registration"

  smtp_server {
    host = "mail.archlinux.org"
    from = "accounts@archlinux.org"
    port = "587"
    from_display_name = "Arch Linux Accounts"
    ssl = false
    starttls = true

    auth {
      username = data.external.keycloak_smtp_user.result.vault_keycloak_smtp_user
      password = data.external.keycloak_smtp_password.result.vault_keycloak_smtp_password
    }
  }

  security_defenses {
    headers {
      x_frame_options                     = "ALLOW-FROM https://www.google.com"
      content_security_policy             = "frame-src 'self' https://www.google.com; frame-ancestors 'self'; object-src 'none';"
      content_security_policy_report_only = ""
      x_content_type_options              = "nosniff"
      x_robots_tag                        = "none"
      x_xss_protection                    = "1; mode=block"
      strict_transport_security           = "max-age=31536000; includeSubDomains"
    }
    brute_force_detection {
      permanent_lockout                 = false
      max_login_failures                = 30
      wait_increment_seconds            = 60
      quick_login_check_milli_seconds   = 1000
      minimum_quick_login_wait_seconds  = 60
      max_failure_wait_seconds          = 900
      failure_reset_time_seconds        = 43200
    }
  }
}

resource "keycloak_saml_client" "saml_gitlab" {
  realm_id = "archlinux"
  client_id = "saml_gitlab"

  name = "Arch Linux Accounts"
  enabled = true

  sign_documents = true
  sign_assertions = true

  valid_redirect_uris = [
    var.gitlab_instance.saml_redirect_url
  ]

  root_url = var.gitlab_instance.root_url
  base_url = "/"
  master_saml_processing_url = var.gitlab_instance.saml_redirect_url
  idp_initiated_sso_url_name = "saml_gitlab"

  assertion_consumer_post_url = var.gitlab_instance.saml_redirect_url
}

// This client is only used for the return URL redirect hack!
// See roles/gitlab/tasks/main.yml
resource "keycloak_openid_client" "openid_gitlab" {
  realm_id = "archlinux"
  client_id = "openid_gitlab"

  name = "Arch Linux Accounts"
  enabled = true

  access_type = "PUBLIC"
  standard_flow_enabled = true
  valid_redirect_uris = [
    "https://gitlab.archlinux.org"
  ]
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_saml_email" {
  realm_id = "archlinux"
  client_id = keycloak_saml_client.saml_gitlab.id

  name = "email"
  user_property = "Email"
  friendly_name = "Email"
  saml_attribute_name = "email"
  saml_attribute_name_format = "Basic"
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_saml_first_name" {
  realm_id = "archlinux"
  client_id = keycloak_saml_client.saml_gitlab.id

  name = "first_name"
  user_property = "FirstName"
  friendly_name = "First Name"
  saml_attribute_name = "first_name"
  saml_attribute_name_format = "Basic"
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_saml_last_name" {
  realm_id = "archlinux"
  client_id = keycloak_saml_client.saml_gitlab.id

  name = "last_name"
  user_property = "LastName"
  friendly_name = "Last Name"
  saml_attribute_name = "last_name"
  saml_attribute_name_format = "Basic"
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_saml_username" {
  realm_id = "archlinux"
  client_id = keycloak_saml_client.saml_gitlab.id

  name = "username"
  user_property = "Username"
  friendly_name = "Username"
  saml_attribute_name = "username"
  saml_attribute_name_format = "Basic"
}

// This is the super group in which we put the other Arch groups.
// We want to end up with this structure:
// Arch Linux Staff
// |- DevOps
// |- Developers
// |- Trusted Users
// External Contributors
resource "keycloak_group" "staff" {
  realm_id = "archlinux"
  name = "Arch Linux Staff"
}

resource "keycloak_group" "externalcontributors" {
  realm_id = "archlinux"
  name = "External Contributors"
}

variable "arch_groups" {
  type = set(string)
  default = ["DevOps", "Developers", "Trusted Users"]
}

resource "keycloak_group" "arch_groups" {
  for_each = var.arch_groups

  realm_id = "archlinux"
  parent_id = keycloak_group.staff.id
  name = each.value
}

resource "keycloak_role" "devops" {
  realm_id = "archlinux"
  name = "DevOps"
  description = "Role held by members of the DevOps group"
}

resource "keycloak_role" "staff" {
  realm_id = "archlinux"
  name = "Staff"
  description = "Role held by all Arch Linux staff"
}

resource "keycloak_role" "externalcontributor" {
  realm_id = "archlinux"
  name = "External Contributor"
  description = "Role held by external contributors working on Arch Linux projects without further access"
}

resource "keycloak_group_roles" "devops" {
  realm_id = "archlinux"
  group_id = keycloak_group.arch_groups["DevOps"].id
  role_ids = [
    keycloak_role.devops.id
  ]
}

resource "keycloak_group_roles" "staff" {
  realm_id = "archlinux"
  group_id = keycloak_group.staff.id
  role_ids = [
    keycloak_role.staff.id
  ]
}

resource "keycloak_group_roles" "externalcontributor" {
  realm_id = "archlinux"
  group_id = keycloak_group.externalcontributors.id
  role_ids = [
    keycloak_role.externalcontributor.id
  ]
}

// Add new custom registration flow with reCAPTCHA
resource "keycloak_authentication_flow" "arch_registration_flow" {
  realm_id = "archlinux"
  alias = "Arch Registration"
  description = "Customized Registration flow that forces enables ReCAPTCHA."
}

resource "keycloak_authentication_subflow" "registration_form" {
  realm_id = "archlinux"
  alias = "Registration Form"
  parent_flow_alias = keycloak_authentication_flow.arch_registration_flow.alias
  provider_id = "form-flow"
  authenticator = "registration-page-form"
  requirement = "REQUIRED"
}

resource "keycloak_authentication_execution" "registration_user_creation" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.registration_form.alias
  authenticator = "registration-user-creation"
  requirement = "REQUIRED"
}

resource "keycloak_authentication_execution" "registration_profile_action" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.registration_form.alias
  authenticator = "registration-profile-action"
  requirement = "REQUIRED"
  depends_on = [keycloak_authentication_execution.registration_user_creation]
}

resource "keycloak_authentication_execution" "registration_password_action" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.registration_form.alias
  authenticator = "registration-password-action"
  requirement = "REQUIRED"
  depends_on = [keycloak_authentication_execution.registration_profile_action]
}

resource "keycloak_authentication_execution" "registration_recaptcha_action" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.registration_form.alias
  authenticator = "registration-recaptcha-action"
  requirement = "REQUIRED"
  depends_on = [keycloak_authentication_execution.registration_password_action]
}

resource "keycloak_authentication_execution_config" "registration_recaptcha_action_config" {
  realm_id = "archlinux"
  alias = "reCAPTCHA config"
  execution_id = keycloak_authentication_execution.registration_recaptcha_action.id
  config = {
    "useRecaptchaNet" = "false",
    "site.key" = data.external.google_recaptcha_site_key.result.vault_google_recaptcha_site_key
    "secret" = data.external.google_recaptcha_secret_key.result.vault_google_recaptcha_secret_key
  }
}

// Add new custom browser login flow with forced OTP for some user roles
//
// Try misc/kcadm_wrapper.sh get authentication/flows/{{ your flow alias}}/executions
// to make this a whole lot easier.
// NOTE: We use the `depends_on` calls to properly order the executions and subflows inside the
// flow. This has to be done until https://github.com/mrparkers/terraform-provider-keycloak/issues/296
// is fixed. :(
// We want to end up with something like this:
//
// Arch Browser flow
// |- Cookie (A)
// |- Identity Provider Redirector (A)
// |- Password and OTP Subflow (A)
//   |- Username Password Form (R)
//   |- OTP Subflow (R)
//      |- External Contributor subflow (A)
//      |  |- External Contributor conditional subflow (C)
//      |     |- Condition - User Role (External Contributor) (R)
//      |     |- OTP Form (R)
//      |- Staff Subflow (A)
//      |  |- Staff conditional subflow (C)
//      |     |- Condition - User Role (Staff) (R)
//      |     |- OTP Form (R)
//      |- OTP opt-in Subflow (A)
//      |  |- OTP opt-in conditional subflow (C)
//      |     |- Condition - User Configured (R)
//      |     |- OTP Form (R)
//      |- Fallthrough Subflow (A)
//         |- Browser Redirect/Refresh (R)
//
// We have the Browser Redirect/Refresh execution at the end as a hack an as an effective "always true" fallthrough no-op.
// Otherwise we'll get a runtime exception as it could happen that none of the Conditions in the Alternative subflows
// matches. Apparently Keycloak doesn't like that and so we'll have to give it something that's always true.

resource "keycloak_authentication_flow" "arch_browser_flow" {
  realm_id = "archlinux"
  alias = "Arch Browser"
  description = "Customized Browser flow that forces users of some roles to use OTP."
}

resource "keycloak_authentication_execution" "cookie" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_flow.arch_browser_flow.alias
  authenticator = "auth-cookie"
  requirement = "ALTERNATIVE"
  depends_on = [keycloak_authentication_flow.arch_browser_flow]
}

resource "keycloak_authentication_execution" "identity_provider_redirector" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_flow.arch_browser_flow.alias
  authenticator = "identity-provider-redirector"
  requirement = "ALTERNATIVE"
  depends_on = [keycloak_authentication_execution.cookie]
}

resource "keycloak_authentication_subflow" "password_and_otp_subflow" {
  realm_id = "archlinux"
  alias = "Password and OTP subflow"
  parent_flow_alias = keycloak_authentication_flow.arch_browser_flow.alias
  requirement = "ALTERNATIVE"
  depends_on = [keycloak_authentication_execution.identity_provider_redirector]
}

resource "keycloak_authentication_execution" "username_password_form" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.password_and_otp_subflow.alias
  authenticator = "auth-username-password-form"
  requirement = "REQUIRED"
}

resource "keycloak_authentication_subflow" "otp" {
  realm_id = "archlinux"
  alias = "OTP subflow"
  parent_flow_alias = keycloak_authentication_subflow.password_and_otp_subflow.alias
  requirement = "REQUIRED"
  depends_on = [keycloak_authentication_execution.username_password_form]
}

resource "keycloak_authentication_subflow" "external_contributor" {
  realm_id = "archlinux"
  alias = "External Contributor subflow"
  parent_flow_alias = keycloak_authentication_subflow.otp.alias
  requirement = "ALTERNATIVE"
}

resource "keycloak_authentication_subflow" "external_contributor_conditional" {
  realm_id = "archlinux"
  alias = "External Contributor conditional"
  parent_flow_alias = keycloak_authentication_subflow.external_contributor.alias
  requirement = "CONDITIONAL"
}

resource "keycloak_authentication_execution" "external_contributor_conditional_user_role" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.external_contributor_conditional.alias
  authenticator = "conditional-user-role"
  requirement = "REQUIRED"
}

resource "keycloak_authentication_execution_config" "external_contributor_conditional_user_role_config" {
  realm_id = "archlinux"
  alias = "External Contributor User Role Config"
  execution_id = keycloak_authentication_execution.external_contributor_conditional_user_role.id
  config = {
    condUserRole = "External Contributor"
  }
}

resource "keycloak_authentication_execution" "external_contributor_conditional_form" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.external_contributor_conditional.alias
  authenticator = "auth-otp-form"
  requirement = "REQUIRED"
  depends_on = [keycloak_authentication_execution.external_contributor_conditional_user_role]
}

resource "keycloak_authentication_subflow" "staff" {
  realm_id = "archlinux"
  alias = "Staff subflow"
  parent_flow_alias = keycloak_authentication_subflow.otp.alias
  requirement = "ALTERNATIVE"
  depends_on = [keycloak_authentication_subflow.external_contributor]
}

resource "keycloak_authentication_subflow" "staff_conditional" {
  realm_id = "archlinux"
  alias = "Staff conditional"
  parent_flow_alias = keycloak_authentication_subflow.staff.alias
  requirement = "CONDITIONAL"
}

resource "keycloak_authentication_execution" "staff_conditional_user_role" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.staff_conditional.alias
  authenticator = "conditional-user-role"
  requirement = "REQUIRED"
}

resource "keycloak_authentication_execution_config" "staff_conditional_user_role_config" {
  realm_id = "archlinux"
  alias = "Staff User Role Config"
  execution_id = keycloak_authentication_execution.staff_conditional_user_role.id
  config = {
    condUserRole = "Staff"
  }
}

resource "keycloak_authentication_execution" "staff_conditional_form" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.staff_conditional.alias
  authenticator = "auth-otp-form"
  requirement = "REQUIRED"
  depends_on = [keycloak_authentication_execution.staff_conditional_user_role]
}

resource "keycloak_authentication_subflow" "otp_opt_in" {
  realm_id = "archlinux"
  alias = "OTP opt-in subflow"
  parent_flow_alias = keycloak_authentication_subflow.otp.alias
  requirement = "ALTERNATIVE"
  depends_on = [keycloak_authentication_subflow.staff]
}

resource "keycloak_authentication_subflow" "otp_opt_in_conditional" {
  realm_id = "archlinux"
  alias = "OTP opt-in conditional"
  parent_flow_alias = keycloak_authentication_subflow.otp_opt_in.alias
  requirement = "CONDITIONAL"
}

resource "keycloak_authentication_execution" "otp_opt_in_conditional_user_configured" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.otp_opt_in_conditional.alias
  authenticator = "conditional-user-configured"
  requirement = "REQUIRED"
}

resource "keycloak_authentication_execution" "otp_opt_in_conditional_form" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.otp_opt_in_conditional.alias
  authenticator = "auth-otp-form"
  requirement = "REQUIRED"
  depends_on = [keycloak_authentication_execution.otp_opt_in_conditional_user_configured]
}

resource "keycloak_authentication_subflow" "fallthrough" {
  realm_id = "archlinux"
  alias = "Fallthrough subflow"
  parent_flow_alias = keycloak_authentication_subflow.otp.alias
  requirement = "ALTERNATIVE"
  depends_on = [keycloak_authentication_subflow.otp_opt_in]
}

resource "keycloak_authentication_execution" "fallthrough_browser_redirect_refresh" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.fallthrough.alias
  authenticator = "no-cookie-redirect"
  requirement = "REQUIRED"
}

output "gitlab_saml_configuration" {
  value = {
    issuer = keycloak_saml_client.saml_gitlab.client_id
    assertion_consumer_service_url = var.gitlab_instance.saml_redirect_url
    admin_groups = [keycloak_role.devops.name]
    idp_sso_target_url = "https://accounts.archlinux.org/auth/realms/archlinux/protocol/saml/clients/${keycloak_saml_client.saml_gitlab.client_id}"
    signing_certificate_fingerprint = keycloak_saml_client.saml_gitlab.signing_certificate
  }
}
