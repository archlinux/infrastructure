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

// Try misc/kcadm_wrapper.sh get authentication/flows/{{ your flow alias}}/executions
// to make this a whole lot easier.
// NOTE: We use the `depends_on` calls to properly order the executions and subflows inside the
// flow. This has to be done until https://github.com/mrparkers/terraform-provider-keycloak/issues/296
// is fixed. :(
resource "keycloak_authentication_flow" "arch_browser_flow" {
  realm_id = "archlinux"
  alias = "Arch Browser"
  description = "Customized Browser flow that forces all users with the 'Staff' role to use OTP."
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

resource "keycloak_authentication_subflow" "subforms" {
  realm_id = "archlinux"
  alias = "subforms"
  parent_flow_alias = keycloak_authentication_flow.arch_browser_flow.alias
  requirement = "ALTERNATIVE"
  depends_on = [keycloak_authentication_execution.identity_provider_redirector]
}

resource "keycloak_authentication_execution" "username_password_form" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.subforms.alias
  authenticator = "auth-username-password-form"
  requirement = "REQUIRED"
}

resource "keycloak_authentication_subflow" "userconfigured_conditional_otp" {
  realm_id = "archlinux"
  alias = "User-configured Conditional OTP"
  parent_flow_alias = keycloak_authentication_subflow.subforms.alias
  requirement = "CONDITIONAL"
  depends_on = [keycloak_authentication_execution.username_password_form]
}

resource "keycloak_authentication_execution" "userconfigured_conditional_otp_condition" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.userconfigured_conditional_otp.alias
  authenticator = "conditional-user-configured"
  requirement = "REQUIRED"
}

resource "keycloak_authentication_execution" "userconfigured_conditional_otp_form" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.userconfigured_conditional_otp.alias
  authenticator = "auth-otp-form"
  requirement = "REQUIRED"
}

resource "keycloak_authentication_execution" "forced_otp_for_staff" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.subforms.alias
  authenticator = "auth-conditional-otp-form"
  requirement = "REQUIRED"
  depends_on = [keycloak_authentication_subflow.userconfigured_conditional_otp]
}

resource "keycloak_authentication_execution_config" "forced_otp_for_staff_config" {
  realm_id = "archlinux"
  execution_id = keycloak_authentication_execution.forced_otp_for_staff.id
  alias = "forced_otp_for_staff_config"
  config = {
    forceOtpRole = "Staff",
    defaultOtpOutcome = "skip"
  }
}

resource "keycloak_authentication_execution" "forced_otp_for_externalcontributors" {
  realm_id = "archlinux"
  parent_flow_alias = keycloak_authentication_subflow.subforms.alias
  authenticator = "auth-conditional-otp-form"
  requirement = "REQUIRED"
  depends_on = [keycloak_authentication_execution.forced_otp_for_staff]
}

resource "keycloak_authentication_execution_config" "forced_otp_for_externalcontributors_config" {
  realm_id = "archlinux"
  execution_id = keycloak_authentication_execution.forced_otp_for_externalcontributors.id
  alias = "forced_otp_for_externalcontributorsconfig"
  config = {
    forceOtpRole = "External Contributor",
    defaultOtpOutcome = "skip"
  }
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
