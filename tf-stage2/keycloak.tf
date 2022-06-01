terraform {
  backend "pg" {
    schema_name = "terraform_remote_state_stage2"
  }
}

data "external" "vault_keycloak" {
  program = ["${path.module}/../misc/get_key.py", "${path.module}/../group_vars/all/vault_keycloak.yml",
    "vault_keycloak_admin_user",
    "vault_keycloak_admin_password",
    "vault_keycloak_smtp_user",
    "vault_keycloak_smtp_password",
    "vault_keycloak_gluebuddy_openid_client_secret",
  "--format", "json"]
}

data "external" "vault_google" {
  program = ["${path.module}/../misc/get_key.py", "${path.module}/../group_vars/all/vault_google.yml",
    "vault_google_recaptcha_site_key",
    "vault_google_recaptcha_secret_key",
  "--format", "json"]
}

data "external" "vault_github" {
  program = ["${path.module}/../misc/get_key.py", "${path.module}/../group_vars/all/vault_github.yml",
    "vault_github_oauth_app_client_id",
    "vault_github_oauth_app_client_secret",
  "--format", "json"]
}

data "external" "vault_monitoring" {
  program = ["${path.module}/../misc/get_key.py", "${path.module}/../group_vars/all/vault_monitoring.yml",
    "vault_monitoring_grafana_client_secret",
  "--format", "json"]
}

data "external" "vault_hedgedoc" {
  program = ["${path.module}/../misc/get_key.py", "${path.module}/../group_vars/all/vault_hedgedoc.yml",
    "vault_hedgedoc_client_secret",
  "--format", "json"]
}

data "external" "vault_matrix" {
  program = ["${path.module}/../misc/get_key.py", "${path.module}/../group_vars/all/vault_matrix.yml",
    "vault_matrix_openid_client_secret",
  "--format", "json"]
}

data "external" "vault_security_tracker" {
  program = ["${path.module}/../misc/get_key.py", "${path.module}/../group_vars/all/vault_security_tracker.yml",
    "vault_security_tracker_openid_client_secret",
  "--format", "json"]
}

provider "keycloak" {
  client_id = "admin-cli"
  username  = data.external.vault_keycloak.result.vault_keycloak_admin_user
  password  = data.external.vault_keycloak.result.vault_keycloak_admin_password
  url       = "https://accounts.archlinux.org"
}

variable "gitlab_instance" {
  default = {
    root_url          = "https://gitlab.archlinux.org"
    saml_redirect_url = "https://gitlab.archlinux.org/users/auth/saml/callback"
  }
}

resource "keycloak_realm" "archlinux" {
  realm             = "archlinux"
  enabled           = true
  remember_me       = true
  display_name      = "Arch Linux"
  display_name_html = "<div class=\"kc-logo-text\"><span>Arch Linux</span></div>"

  registration_allowed     = true
  reset_password_allowed   = true
  verify_email             = true
  login_with_email_allowed = true
  password_policy          = "length(8) and notUsername"

  web_authn_policy {
    relying_party_entity_name = "Arch Linux SSO"
    relying_party_id          = "accounts.archlinux.org"
    signature_algorithms      = ["ES256", "RS256", "ES512", "RS512"]
  }

  login_theme   = "archlinux"
  account_theme = "archlinux"
  admin_theme   = "archlinux"

  browser_flow           = "Arch Browser"
  registration_flow      = "Arch Registration"
  reset_credentials_flow = "Arch Reset Credentials"

  smtp_server {
    host              = "mail.archlinux.org"
    from              = "accounts@archlinux.org"
    port              = "465"
    from_display_name = "Arch Linux Accounts"
    ssl               = true
    starttls          = false

    auth {
      username = data.external.vault_keycloak.result.vault_keycloak_smtp_user
      password = data.external.vault_keycloak.result.vault_keycloak_smtp_password
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
      permanent_lockout                = false
      max_login_failures               = 30
      wait_increment_seconds           = 60
      quick_login_check_milli_seconds  = 1000
      minimum_quick_login_wait_seconds = 60
      max_failure_wait_seconds         = 900
      failure_reset_time_seconds       = 43200
    }
  }
}

resource "keycloak_required_action" "custom-terms-and-conditions" {
  realm_id       = "archlinux"
  alias          = "terms_and_conditions"
  default_action = true
  enabled        = true
  name           = "Terms and Conditions"
}

resource "keycloak_required_action" "configure_otp" {
  realm_id       = "archlinux"
  alias          = "CONFIGURE_TOTP"
  default_action = true
  enabled        = true
  name           = "Configure OTP"
  priority       = 0
}

resource "keycloak_required_action" "update_password" {
  realm_id = "archlinux"
  alias    = "UPDATE_PASSWORD"
  enabled  = true
  name     = "Update Password"
  priority = 20
}

resource "keycloak_required_action" "update_profile" {
  realm_id = "archlinux"
  alias    = "UPDATE_PROFILE"
  enabled  = true
  name     = "Update Profile"
  priority = 30
}

resource "keycloak_required_action" "verify_email" {
  realm_id = "archlinux"
  alias    = "VERIFY_EMAIL"
  enabled  = true
  name     = "Verify Email"
  priority = 40
}

resource "keycloak_required_action" "update_user_locale" {
  realm_id = "archlinux"
  alias    = "update_user_locale"
  enabled  = true
  name     = "Update User Locale"
  priority = 50
}

resource "keycloak_required_action" "webauthn_register" {
  realm_id = "archlinux"
  alias    = "webauthn-register"
  enabled  = true
  name     = "Webauthn Register"
  priority = 60
}

resource "keycloak_realm_events" "realm_events" {
  realm_id = "archlinux"

  events_enabled    = true
  events_expiration = 7889238 # 3 months

  admin_events_enabled         = true
  admin_events_details_enabled = true

  # When omitted or left empty, keycloak will enable all event types
  enabled_event_types = [
  ]

  events_listeners = [
    "jboss-logging",    # keycloak enables the 'jboss-logging' event listener by default.
    "metrics-listener", # enable the prometheus exporter (keycloak-metrics-spi)
  ]
}

resource "keycloak_oidc_identity_provider" "realm_identity_provider" {
  realm                        = "archlinux"
  alias                        = "github"
  provider_id                  = "github"
  authorization_url            = "https://accounts.archlinux.org/auth/realms/archlinux/broker/github/endpoint"
  client_id                    = data.external.vault_github.result.vault_github_oauth_app_client_id
  client_secret                = data.external.vault_github.result.vault_github_oauth_app_client_secret
  token_url                    = ""
  default_scopes               = ""
  post_broker_login_flow_alias = keycloak_authentication_flow.arch_post_ipr_flow.alias
  enabled                      = true
  trust_email                  = false
  store_token                  = false
  backchannel_supported        = false
  sync_mode                    = "IMPORT"
}

resource "keycloak_saml_client" "saml_gitlab" {
  realm_id  = "archlinux"
  client_id = "saml_gitlab"

  name    = "Arch Linux GitLab"
  enabled = true

  signature_algorithm = "RSA_SHA256"
  sign_documents      = true
  sign_assertions     = true

  valid_redirect_uris = [
    var.gitlab_instance.saml_redirect_url
  ]

  root_url                   = var.gitlab_instance.root_url
  base_url                   = "/"
  master_saml_processing_url = var.gitlab_instance.saml_redirect_url
  idp_initiated_sso_url_name = "saml_gitlab"
  front_channel_logout       = false

  assertion_consumer_post_url = var.gitlab_instance.saml_redirect_url
}

// This client is only used for the return URL redirect hack!
// See roles/gitlab/tasks/main.yml
resource "keycloak_openid_client" "openid_gitlab" {
  realm_id  = "archlinux"
  client_id = "openid_gitlab"

  name    = "Arch Linux Accounts"
  enabled = true

  access_type           = "PUBLIC"
  standard_flow_enabled = true
  use_refresh_tokens    = false
  full_scope_allowed    = false
  valid_redirect_uris = [
    "https://gitlab.archlinux.org"
  ]
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_saml_email" {
  realm_id  = "archlinux"
  client_id = keycloak_saml_client.saml_gitlab.id

  name                       = "email"
  user_property              = "Email"
  friendly_name              = "Email"
  saml_attribute_name        = "email"
  saml_attribute_name_format = "Basic"
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_saml_first_name" {
  realm_id  = "archlinux"
  client_id = keycloak_saml_client.saml_gitlab.id

  name                       = "first_name"
  user_property              = "FirstName"
  friendly_name              = "First Name"
  saml_attribute_name        = "first_name"
  saml_attribute_name_format = "Basic"
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_saml_last_name" {
  realm_id  = "archlinux"
  client_id = keycloak_saml_client.saml_gitlab.id

  name                       = "last_name"
  user_property              = "LastName"
  friendly_name              = "Last Name"
  saml_attribute_name        = "last_name"
  saml_attribute_name_format = "Basic"
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_saml_username" {
  realm_id  = "archlinux"
  client_id = keycloak_saml_client.saml_gitlab.id

  name                       = "username"
  user_property              = "Username"
  friendly_name              = "Username"
  saml_attribute_name        = "username"
  saml_attribute_name_format = "Basic"
}

// This is the super group in which we put the other Arch groups.
// We want to end up with this structure:
// Arch Linux Staff
// |- DevOps
// |- Developers
// |- Trusted Users
// |- Wiki
// |  |- Admins
// |  |- Maintainers
// |- Forum
// |  |- Admins
// |  |- Mods
// |- Security Team
// |  |- Admins
// |  |- Members
// |- IRC
// |  |- Ops
// |- Archweb
// |  |- Mirrorlist Maintainers
// |- Bug Wranglers
// |- Project Maintainers
// External Contributors
// |- Security Team
// |  |- Reporters
// |- Archweb
//    |- Testers
resource "keycloak_group" "staff" {
  realm_id = "archlinux"
  name     = "Arch Linux Staff"
}

resource "keycloak_group" "staff_groups" {
  for_each = toset(["DevOps", "Developers", "Trusted Users", "Wiki", "Forum", "Security Team", "IRC", "Archweb", "Bug Wranglers", "Project Maintainers"])

  realm_id  = "archlinux"
  parent_id = keycloak_group.staff.id
  name      = each.value
}

resource "keycloak_group" "staff_wiki_groups" {
  for_each = toset(["Admins", "Maintainers"])

  realm_id  = "archlinux"
  parent_id = keycloak_group.staff_groups["Wiki"].id
  name      = each.value
}

resource "keycloak_group" "staff_forum_groups" {
  for_each = toset(["Admins", "Mods"])

  realm_id  = "archlinux"
  parent_id = keycloak_group.staff_groups["Forum"].id
  name      = each.value
}

resource "keycloak_group" "staff_securityteam_groups" {
  for_each = toset(["Admins", "Members"])

  realm_id  = "archlinux"
  parent_id = keycloak_group.staff_groups["Security Team"].id
  name      = each.value
}

resource "keycloak_group" "staff_irc_groups" {
  for_each = toset(["Ops"])

  realm_id  = "archlinux"
  parent_id = keycloak_group.staff_groups["IRC"].id
  name      = each.value
}

resource "keycloak_group" "staff_archweb_groups" {
  for_each = toset(["Mirrorlist Maintainers"])

  realm_id  = "archlinux"
  parent_id = keycloak_group.staff_groups["Archweb"].id
  name      = each.value
}

resource "keycloak_group" "externalcontributors" {
  realm_id = "archlinux"
  name     = "External Contributors"
}

resource "keycloak_group" "externalcontributors_groups" {
  for_each = toset(["Security Team", "Archweb"])

  realm_id  = "archlinux"
  parent_id = keycloak_group.externalcontributors.id
  name      = each.value
}

resource "keycloak_group" "externalcontributors_securityteam_groups" {
  for_each = toset(["Reporters"])

  realm_id  = "archlinux"
  parent_id = keycloak_group.externalcontributors_groups["Security Team"].id
  name      = each.value
}

resource "keycloak_group" "externalcontributors_archweb_groups" {
  for_each = toset(["Testers"])

  realm_id  = "archlinux"
  parent_id = keycloak_group.externalcontributors_groups["Archweb"].id
  name      = each.value
}

resource "keycloak_role" "devops" {
  realm_id    = "archlinux"
  name        = "DevOps"
  description = "Role held by members of the DevOps group"
}

resource "keycloak_role" "staff" {
  realm_id    = "archlinux"
  name        = "Staff"
  description = "Role held by all Arch Linux staff"
}

resource "keycloak_role" "externalcontributor" {
  realm_id    = "archlinux"
  name        = "External Contributor"
  description = "Role held by external contributors working on Arch Linux projects without further access"
}

resource "keycloak_group_roles" "devops" {
  realm_id = "archlinux"
  group_id = keycloak_group.staff_groups["DevOps"].id
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
  realm_id    = "archlinux"
  alias       = "Arch Registration"
  description = "Customized Registration flow that forces enables ReCAPTCHA."
}

resource "keycloak_authentication_subflow" "registration_form" {
  realm_id          = "archlinux"
  alias             = "Registration Form"
  parent_flow_alias = keycloak_authentication_flow.arch_registration_flow.alias
  provider_id       = "form-flow"
  authenticator     = "registration-page-form"
  requirement       = "REQUIRED"
}

resource "keycloak_authentication_execution" "registration_user_creation" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.registration_form.alias
  authenticator     = "registration-user-creation"
  requirement       = "REQUIRED"
}

resource "keycloak_authentication_execution" "registration_profile_action" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.registration_form.alias
  authenticator     = "registration-profile-action"
  requirement       = "REQUIRED"
  depends_on        = [keycloak_authentication_execution.registration_user_creation]
}

resource "keycloak_authentication_execution" "registration_password_action" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.registration_form.alias
  authenticator     = "registration-password-action"
  requirement       = "REQUIRED"
  depends_on        = [keycloak_authentication_execution.registration_profile_action]
}

resource "keycloak_authentication_execution" "registration_recaptcha_action" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.registration_form.alias
  authenticator     = "registration-recaptcha-action"
  requirement       = "REQUIRED"
  depends_on        = [keycloak_authentication_execution.registration_password_action]
}

resource "keycloak_authentication_execution_config" "registration_recaptcha_action_config" {
  realm_id     = "archlinux"
  alias        = "reCAPTCHA config"
  execution_id = keycloak_authentication_execution.registration_recaptcha_action.id
  config = {
    "useRecaptchaNet" = "false",
    "site.key"        = data.external.vault_google.result.vault_google_recaptcha_site_key
    "secret"          = data.external.vault_google.result.vault_google_recaptcha_secret_key
  }
}

// Add new custom browser login flow with WebAuthn support and forced OTP.
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
// |- Password and 2FA Subflow (A)
//   |- Username Password Form (R)
//   |- 2FA Subflow (R)
//      |- WebAuthn Authenticator (A)
//      |- OTP Form (A)
//      |- OTP Default Subflow (A)
//         |- OTP Form (R)
//
// IMPORTANT NOTE: Sometimes when changing Authentication Flows via Terraform or UI, flows can become orphaned in which
// case they'll hang around the database doing nothing useful and blocking alias names and causing 409 CONFLICTS. If such
// a thing happens, you'll have to get dirty and and manually clean up the authentication_flows and authentication_executions
// tables on the Keycloak Postgres DB! Quality Red Hat software right there.

resource "keycloak_authentication_flow" "arch_browser_flow" {
  realm_id    = "archlinux"
  alias       = "Arch Browser"
  description = "Customized Browser flow that forces 2FA."
}

resource "keycloak_authentication_execution" "cookie" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_flow.arch_browser_flow.alias
  authenticator     = "auth-cookie"
  requirement       = "ALTERNATIVE"
  depends_on        = [keycloak_authentication_flow.arch_browser_flow]
}

resource "keycloak_authentication_execution" "identity_provider_redirector" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_flow.arch_browser_flow.alias
  authenticator     = "identity-provider-redirector"
  requirement       = "ALTERNATIVE"
  depends_on        = [keycloak_authentication_execution.cookie]
}

resource "keycloak_authentication_subflow" "password_and_2fa" {
  realm_id          = "archlinux"
  alias             = "Password and 2FA subflow"
  parent_flow_alias = keycloak_authentication_flow.arch_browser_flow.alias
  requirement       = "ALTERNATIVE"
  depends_on        = [keycloak_authentication_execution.identity_provider_redirector]
}

resource "keycloak_authentication_execution" "username_password_form" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.password_and_2fa.alias
  authenticator     = "auth-username-password-form"
  requirement       = "REQUIRED"
}

resource "keycloak_authentication_subflow" "_2fa" {
  realm_id          = "archlinux"
  alias             = "2FA subflow"
  parent_flow_alias = keycloak_authentication_subflow.password_and_2fa.alias
  requirement       = "REQUIRED"
  depends_on        = [keycloak_authentication_execution.username_password_form]
}

resource "keycloak_authentication_execution" "webauthn_form" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow._2fa.alias
  authenticator     = "webauthn-authenticator"
  requirement       = "ALTERNATIVE"
}

resource "keycloak_authentication_execution" "otp_form" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow._2fa.alias
  authenticator     = "auth-otp-form"
  requirement       = "ALTERNATIVE"
  depends_on        = [keycloak_authentication_execution.webauthn_form]
}

resource "keycloak_authentication_subflow" "otp_default" {
  realm_id          = "archlinux"
  alias             = "OTP Default Subflow"
  parent_flow_alias = keycloak_authentication_subflow._2fa.alias
  requirement       = "ALTERNATIVE"
  depends_on        = [keycloak_authentication_execution.otp_form]
}

resource "keycloak_authentication_execution" "otp_default_form" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.otp_default.alias
  authenticator     = "auth-otp-form"
  requirement       = "REQUIRED"
}

// Add new custom post-Identity Provider login flow with forced OTP for some user roles
//
// Arch Post IPR Flow
// |- WebAuthn Form (A)
// |- OTP Form (A)
// |- IPR OTP Default Subflow (A)
//    |- OTP Form (R)

resource "keycloak_authentication_flow" "arch_post_ipr_flow" {
  realm_id    = "archlinux"
  alias       = "Arch Post IPR Flow"
  description = "Post IPR login flow that forces 2FA."
}

resource "keycloak_authentication_execution" "ipr_webauthn_form" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_flow.arch_post_ipr_flow.alias
  authenticator     = "webauthn-authenticator"
  requirement       = "ALTERNATIVE"
}

resource "keycloak_authentication_execution" "ipr_otp_form" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_flow.arch_post_ipr_flow.alias
  authenticator     = "auth-otp-form"
  requirement       = "ALTERNATIVE"
  depends_on        = [keycloak_authentication_execution.ipr_webauthn_form]
}

resource "keycloak_authentication_subflow" "ipr_otp_default" {
  realm_id          = "archlinux"
  alias             = "IPR OTP Default Subflow"
  parent_flow_alias = keycloak_authentication_flow.arch_post_ipr_flow.alias
  requirement       = "ALTERNATIVE"
  depends_on        = [keycloak_authentication_execution.ipr_otp_form]
}

resource "keycloak_authentication_execution" "ipr_otp_default_form" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.ipr_otp_default.alias
  authenticator     = "auth-otp-form"
  requirement       = "REQUIRED"
}

// Add new custom Reset Credentials flow that asks users to verify 2FA before resetting their password
//
// Arch Reset Credentials
// |- Choose User (R)
// |- Send Reset Email (R)
// |- Conditional Reset Credentials 2FA Subflow (C)
//    |- Condition - User Configured (R)
//    |- Reset Credentials 2FA Subflow (R)
//       |- WebAuthn Form (A)
//       |- OTP Form (A)
//       |- Reset Credentials OTP Default Subflow (A)
//          |- OTP Form (R)
// |- Reset Password (R)

resource "keycloak_authentication_flow" "arch_reset_credentials_flow" {
  realm_id    = "archlinux"
  alias       = "Arch Reset Credentials"
  description = "Reset credentials flow that forces 2FA verification before password reset."
}

resource "keycloak_authentication_execution" "rc_choose_user" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_flow.arch_reset_credentials_flow.alias
  authenticator     = "reset-credentials-choose-user"
  requirement       = "REQUIRED"
}

resource "keycloak_authentication_execution" "rc_reset_email" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_flow.arch_reset_credentials_flow.alias
  authenticator     = "reset-credential-email"
  requirement       = "REQUIRED"
  depends_on        = [keycloak_authentication_execution.rc_choose_user]
}

resource "keycloak_authentication_subflow" "rc_conditional_2fa" {
  realm_id          = "archlinux"
  alias             = "Conditional Reset Credentials 2FA Subflow"
  parent_flow_alias = keycloak_authentication_flow.arch_reset_credentials_flow.alias
  requirement       = "CONDITIONAL"
  depends_on        = [keycloak_authentication_execution.rc_choose_user]
}

resource "keycloak_authentication_execution" "rc_2fa_condition" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.rc_conditional_2fa.alias
  authenticator     = "conditional-user-configured"
  requirement       = "REQUIRED"
}

resource "keycloak_authentication_subflow" "rc_2fa" {
  realm_id          = "archlinux"
  alias             = "Reset Credentials 2FA Subflow"
  parent_flow_alias = keycloak_authentication_subflow.rc_conditional_2fa.alias
  requirement       = "REQUIRED"
  depends_on        = [keycloak_authentication_execution.rc_2fa_condition]
}

resource "keycloak_authentication_execution" "rc_webauthn_form" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.rc_2fa.alias
  authenticator     = "webauthn-authenticator"
  requirement       = "ALTERNATIVE"
}

resource "keycloak_authentication_execution" "rc_otp_form" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.rc_2fa.alias
  authenticator     = "auth-otp-form"
  requirement       = "ALTERNATIVE"
  depends_on        = [keycloak_authentication_execution.rc_webauthn_form]
}

resource "keycloak_authentication_subflow" "rc_otp_default" {
  realm_id          = "archlinux"
  alias             = "Reset Credentials OTP Default Subflow"
  parent_flow_alias = keycloak_authentication_subflow.rc_2fa.alias
  requirement       = "ALTERNATIVE"
  depends_on        = [keycloak_authentication_execution.rc_otp_form]
}

resource "keycloak_authentication_execution" "rc_otp_default_form" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.rc_otp_default.alias
  authenticator     = "auth-otp-form"
  requirement       = "REQUIRED"
}

resource "keycloak_authentication_execution" "rc_reset_password" {
  realm_id          = "archlinux"
  parent_flow_alias = keycloak_authentication_flow.arch_reset_credentials_flow.alias
  authenticator     = "reset-password"
  requirement       = "REQUIRED"
  depends_on        = [keycloak_authentication_subflow.rc_conditional_2fa]
}

output "gitlab_saml_configuration" {
  value = {
    issuer                          = keycloak_saml_client.saml_gitlab.client_id
    assertion_consumer_service_url  = var.gitlab_instance.saml_redirect_url
    admin_groups                    = [keycloak_role.devops.name]
    idp_sso_target_url              = "https://accounts.archlinux.org/auth/realms/archlinux/protocol/saml/clients/${keycloak_saml_client.saml_gitlab.client_id}"
    signing_certificate_fingerprint = keycloak_saml_client.saml_gitlab.signing_certificate
  }
}

resource "keycloak_openid_client" "grafana_openid_client" {
  realm_id      = "archlinux"
  client_id     = "openid_grafana"
  client_secret = data.external.vault_monitoring.result.vault_monitoring_grafana_client_secret

  name    = "Grafana"
  enabled = true

  access_type           = "CONFIDENTIAL"
  standard_flow_enabled = true
  use_refresh_tokens    = false
  valid_redirect_uris = [
    "https://monitoring.archlinux.org",
    "https://monitoring.archlinux.org/login/generic_oauth"
  ]
}

resource "keycloak_openid_user_realm_role_protocol_mapper" "user_realm_role_mapper" {
  realm_id  = "archlinux"
  client_id = keycloak_openid_client.grafana_openid_client.id
  name      = "user realms"

  claim_name          = "roles"
  multivalued         = true
  add_to_id_token     = false
  add_to_access_token = false
}

resource "keycloak_openid_client" "hedgedoc_openid_client" {
  realm_id      = "archlinux"
  client_id     = "openid_hedgedoc"
  client_secret = data.external.vault_hedgedoc.result.vault_hedgedoc_client_secret

  name    = "Hedgedoc"
  enabled = true

  access_type           = "CONFIDENTIAL"
  standard_flow_enabled = true
  use_refresh_tokens    = false
  valid_redirect_uris = [
    "https://md.archlinux.org/*",
  ]
}

resource "keycloak_openid_user_realm_role_protocol_mapper" "hedgedoc_user_realm_role_mapper" {
  realm_id  = "archlinux"
  client_id = keycloak_openid_client.hedgedoc_openid_client.id
  name      = "user realms"

  claim_name          = "roles"
  multivalued         = true
  add_to_id_token     = false
  add_to_access_token = false
}

resource "keycloak_openid_client" "matrix_openid_client" {
  realm_id      = "archlinux"
  client_id     = "openid_matrix"
  client_secret = data.external.vault_matrix.result.vault_matrix_openid_client_secret

  name    = "Matrix"
  enabled = true

  access_type           = "CONFIDENTIAL"
  standard_flow_enabled = true
  use_refresh_tokens    = false
  valid_redirect_uris = [
    "https://matrix.archlinux.org/_synapse/client/oidc/callback"
  ]
}

resource "keycloak_openid_user_realm_role_protocol_mapper" "matrix_user_realm_role_mapper" {
  realm_id  = "archlinux"
  client_id = keycloak_openid_client.matrix_openid_client.id
  name      = "user realms"

  claim_name          = "roles"
  multivalued         = true
  add_to_id_token     = true
  add_to_access_token = false
}

resource "keycloak_openid_client" "gluebuddy_openid_client" {
  realm_id      = "archlinux"
  client_id     = "gluebuddy"
  client_secret = data.external.vault_keycloak.result.vault_keycloak_gluebuddy_openid_client_secret
  web_origins   = []

  name    = "Gluebuddy"
  enabled = true

  service_accounts_enabled = true

  access_type           = "CONFIDENTIAL"
  standard_flow_enabled = true
  use_refresh_tokens    = false
  valid_redirect_uris = [
    "https://gitlab.archlinux.org/"
  ]
}

resource "keycloak_openid_client" "security_tracker_openid_client" {
  realm_id      = "archlinux"
  client_id     = "openid_security_tracker"
  client_secret = data.external.vault_security_tracker.result.vault_security_tracker_openid_client_secret

  name    = "Security Tracker"
  enabled = true

  access_type           = "CONFIDENTIAL"
  standard_flow_enabled = true
  use_refresh_tokens    = false
  web_origins           = []
  valid_redirect_uris = [
    "https://security.archlinux.org/*",
  ]
}

resource "keycloak_openid_group_membership_protocol_mapper" "group_membership_mapper" {
  realm_id  = "archlinux"
  client_id = keycloak_openid_client.security_tracker_openid_client.id
  name      = "group-membership-mapper"

  claim_name = "groups"
}
