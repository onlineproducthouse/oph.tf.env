#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "dns" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/dns/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  image_registry_base_url    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.client_info.region}.amazonaws.com"
  test_user_email_addr_templ = "test-user@${data.terraform_remote_state.dns.outputs.dns.domain_name}"

  shared = [
    { id = "shared_project_name", path = local.paths.shared, key = "PROJECT_NAME", value = var.client_info.project_name },
    { id = "shared_do_not_reply", path = local.paths.shared, key = "NO_REPLY_EMAIL_ADDRESS", value = data.terraform_remote_state.email.outputs.do_not_reply },
    { id = "shared_dkr_repo", path = local.paths.shared, key = "IMAGE_REGISTRY_BASE_URL", value = local.image_registry_base_url },

    { id = "shared_otp_length", path = local.paths.shared, key = "OTP_LENGTH", value = "6" },
    { id = "shared_otp_time_to_live_in_minutes", path = local.paths.shared, key = "OTP_TIME_TO_LIVE_IN_MINUTES", value = "5" },

    { id = "shared_test_user_email_addr_first", path = local.paths.shared, key = "TEST_USER_EMAIL_ADDR_FIRST", value = "first.${local.test_user_email_addr_templ}" },
    { id = "shared_test_user_email_addr_second", path = local.paths.shared, key = "TEST_USER_EMAIL_ADDR_SECOND", value = "second.${local.test_user_email_addr_templ}" },
    { id = "shared_test_user_email_addr_third", path = local.paths.shared, key = "TEST_USER_EMAIL_ADDR_THIRD", value = "third.${local.test_user_email_addr_templ}" },
    { id = "shared_test_user_email_addr_fourth", path = local.paths.shared, key = "TEST_USER_EMAIL_ADDR_FOURTH", value = "fourth.${local.test_user_email_addr_templ}" },
    { id = "shared_test_user_pwd", path = local.paths.shared, key = "TEST_USER_PWD", value = local.shared_secrets.test_user_password },

    { id = "shared_portal_user_email_addr", path = local.paths.shared, key = "PORTAL_USER_EMAIL_ADDR", value = data.terraform_remote_state.email.outputs.root },

    { id = "shared_sg_street", path = local.paths.shared, key = "SG_SENDER_ADDRESS", value = "13-Zebra-Street" },
    { id = "shared_sg_city", path = local.paths.shared, key = "SG_SENDER_CITY", value = "Bronkhorstspruit" },
    { id = "shared_sg_state", path = local.paths.shared, key = "SG_SENDER_STATE", value = "Gauteng" },
    { id = "shared_sg_zip", path = local.paths.shared, key = "SG_SENDER_ZIP", value = "1020" },
    { id = "shared_sg_email_address", path = local.paths.shared, key = "SG_SENDER_EMAIL_ADDRESS", value = data.terraform_remote_state.email.outputs.do_not_reply },

    { id = "shared_sg_new_account_templ_id", path = local.paths.shared, key = "SG_SENDER_NEW_ACCOUNT_TEMPL_ID", value = local.shared_secrets.sg_new_account_templ_id },
    { id = "shared_sg_recover_account_templ_id", path = local.paths.shared, key = "SG_SENDER_RECOVER_ACCOUNT_TEMPL_ID", value = local.shared_secrets.sg_recover_account_templ_id },
    { id = "shared_sg_new_email_addr_templ_id", path = local.paths.shared, key = "SG_SENDER_NEW_EMAIL_ADDR_TEMPL_ID", value = local.shared_secrets.sg_new_email_addr_templ_id },
    { id = "shared_sg_lead_link_invite_templ_id", path = local.paths.shared, key = "SG_SENDER_LEAD_LINK_INVITE_TEMPL_ID", value = local.shared_secrets.sg_lead_link_invite_templ_id },
    { id = "shared_sg_agreement_version_published_templ_id", path = local.paths.shared, key = "SG_SENDER_AGREEMENT_VERSION_PUBLISHED_TEMPL_ID", value = local.shared_secrets.sg_agreement_version_published_templ_id },
    { id = "shared_sg_organisation_member_invite_templ_id", path = local.paths.shared, key = "SG_SENDER_ORGANISATION_MEMBER_INVITE_TEMPL_ID", value = local.shared_secrets.sg_organisation_member_invite_templ_id },
    { id = "shared_sg_lead_signup_closed_templ_id", path = local.paths.shared, key = "SG_SENDER_LEAD_SIGNUP_CLOSED_TEMPL_ID", value = local.shared_secrets.sg_lead_signup_closed_templ_id },
    { id = "shared_sg_lead_pd_new_client_templ_id", path = local.paths.shared, key = "SG_SENDER_LEAD_PD_NEW_CLIENT_TEMPL_ID", value = local.shared_secrets.sg_lead_pd_new_client_templ_id },
    { id = "shared_sg_meeting_request_templ_id", path = local.paths.shared, key = "SG_MEETING_REQUEST_TEMPL_ID", value = local.shared_secrets.sg_meeting_request_templ_id },
    { id = "shared_sg_billing_event_created_templ_id", path = local.paths.shared, key = "SG_BILLING_EVENT_CREATED_TEMPL_ID", value = local.shared_secrets.sg_billing_event_created_templ_id },
    { id = "shared_sg_billing_event_payment_templ_id", path = local.paths.shared, key = "SG_BILLING_EVENT_PAYMENT_TEMPL_ID", value = local.shared_secrets.sg_billing_event_payment_templ_id },
  ]
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
