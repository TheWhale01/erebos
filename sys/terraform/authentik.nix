{ vars, ... }:

{
  provider.authentik = {
    url = "http://127.0.0.1:${toString vars.authentik.port}";
    token = "\${trimspace(file(\"/run/agenix/authentik-terraform\"))}";
  };
  data.authentik_flow.default_authorization_flow.slug = "default-provider-authorization-explicit-consent";
  data.authentik_flow.default_invalidation_flow.slug = "default-provider-invalidation-flow";
  data.authentik_user.whale.username = "whale";
  data.authentik_property_mapping_provider_scope.email.managed = "goauthentik.io/providers/oauth2/scope-email";
  data.authentik_property_mapping_provider_scope.profile.managed = "goauthentik.io/providers/oauth2/scope-profile";
  data.authentik_property_mapping_provider_scope.openid.managed = "goauthentik.io/providers/oauth2/scope-openid";
  data.authentik_property_mapping_provider_scope.offline_access.managed = "goauthentik.io/providers/oauth2/scope-offline_access";
  data.authentik_certificate_key_pair.default = {
    name = "authentik Self-signed Certificate";
  };

  resource = {
    authentik_outpost.proxy_outpost = {
      name = "proxy-outpost";
      protocol_providers = [
        "\${authentik_provider_proxy.openbooks_provider.id}"
        "\${authentik_provider_proxy.sonarr_provider.id}"
        "\${authentik_provider_proxy.maintainerr_provider.id}"
        "\${authentik_provider_proxy.radarr_provider.id}"
        "\${authentik_provider_proxy.prowlarr_provider.id}"
        "\${authentik_provider_proxy.transmission_provider.id}"
        "\${authentik_provider_proxy.traefik_provider.id}"
        "\${authentik_provider_proxy.enableactual_provider.id}"
        "\${authentik_provider_proxy.slskd_provider.id}"
        "\${authentik_provider_proxy.lidarr_provider.id}"
      ];
    };
    authentik_stage_invitation.invitation_stage = {
      name = "invitation-stage";
      continue_flow_without_invitation = false;
    };
    authentik_stage_prompt_field = {
      username = {
        name = "username";
        field_key = "username";
        label = "Username";
        placeholder = "Username";
        type = "username";
        order = 10;
      };
      email = {
        name = "email";
        field_key = "email";
        label = "Email";
        placeholder = "Email";
        type = "email";
        order = 20;
      };
      password = {
        name = "password";
        field_key = "password";
        label = "Password";
        placeholder = "Password";
        type = "password";
        order = 30;
      };
      password_repeat = {
        name = "password-repeat";
        field_key = "password_repeat";
        label = "Password (Repeat)";
        placeholder = "Password (Repeat)";
        type = "password";
        order = 40;
      };
    };
    authentik_stage_prompt = {
      recovery_prompt_stage = {
        name = "recovery-password-prompt";
        fields = [
          "\${authentik_stage_prompt_field.password.id}"
          "\${authentik_stage_prompt_field.password_repeat.id}"
        ];
        validation_policies = [
          "\${authentik_policy_password.password_policy.id}"
        ];
      };
      prompt_stage = {
        name = "prompt";
        fields = [
          "\${authentik_stage_prompt_field.username.id}"
          "\${authentik_stage_prompt_field.email.id}"
          "\${authentik_stage_prompt_field.password.id}"
          "\${authentik_stage_prompt_field.password_repeat.id}"
        ];
        validation_policies = [
          "\${authentik_policy_expression.username_policy.id}"
          "\${authentik_policy_password.password_policy.id}"
        ];
      };
    };
    authentik_stage_email = {
      email_stage = {
        name = "enrollment-email-stage";
        use_global_settings = true;
        subject = "Confirm you account";
        template = "email/account_confirmation.html";
        activate_user_on_success = true;
      };
      recovery_email_stage = {
        name = "recovery-email-stage";
        use_global_settings = true;
        subject = "Password Recovery";
        template = "email/password_reset.html";
      };
    };
    authentik_stage_user_login.user_login_stage = {
      name = "enrollment-user-login";
    };
    authentik_stage_user_write = {
      write_user_stage = {
        name = "write-user-stage";
        create_users_as_inactive = true;
        user_type = "internal";
      };
      recovery_write_user = {
        name = "recovery-user-write";
      };
    };
    authentik_policy_expression = {
      username_policy = {
        name = "username-policy";
        expression = ''
          username = context.get("prompt_data", {}).get("username")
          if not username:
            return False
          if not username.isalnum():
            ak_message("Username can only contain letter and numbers. No spaces or special characters allowed.")
            return False
          return True
        '';
      };
      skip_if_restored = {
        name = "skip-if-restored";
        expression = ''
          return not context.get("is_restored", False)
        '';
      };
    };
    authentik_policy_password.password_policy = {
      name = "password-policy";
      error_message = "Password must be at least 12 characters, include symbols/numbers, and cannot be a common dictionary word or appear in a known data breach.";
      length_min = 12;
      amount_uppercase = 1;
      amount_lowercase = 1;
      amount_digits = 1;
      amount_symbols = 1;
      check_have_i_been_pwned = true;
      check_zxcvbn = true;
      zxcvbn_score_threshold = 3;
    };
    authentik_flow = {
      enrollment_flow = {
        name = "enrollment";
        slug = "enrollment";
        title = "Sign Up";
        designation = "enrollment";
      };
      recovery_password_flow = {
        name = "password-recovery";
        slug = "password-recovery";
        title = "Reset your password";
        designation = "recovery";
      };
    };
    authentik_flow_stage_binding = {
      enrollment_invitation = {
        target = "\${authentik_flow.enrollment_flow.uuid}";
        stage = "\${authentik_stage_invitation.invitation_stage.id}";
        order = 10;
        evaluate_on_plan = true;
      };
      enrollment_prompt = {
        target = "\${authentik_flow.enrollment_flow.uuid}";
        stage = "\${authentik_stage_prompt.prompt_stage.id}";
        order = 20;
      };
      enrollment_user_write = {
        target = "\${authentik_flow.enrollment_flow.uuid}";
        stage = "\${authentik_stage_user_write.write_user_stage.id}";
        order = 30;
      };
      enrollment_email = {
        target = "\${authentik_flow.enrollment_flow.uuid}";
        stage = "\${authentik_stage_email.email_stage.id}";
        order = 40;
      };
      enrollment_login = {
        target = "\${authentik_flow.enrollment_flow.uuid}";
        stage = "\${authentik_stage_user_login.user_login_stage.id}";
        order = 50;
      };
      recovery_identify = {
        target = "\${authentik_flow.recovery_password_flow.uuid}";
        stage = "\${authentik_stage_identification.recovery_identification_stage.id}";
        order = 10;
      };
      recovery_email = {
        target = "\${authentik_flow.recovery_password_flow.uuid}";
        stage = "\${authentik_stage_email.recovery_email_stage.id}";
        order = 20;
      };
      recovery_prompt = {
        target = "\${authentik_flow.recovery_password_flow.uuid}";
        stage = "\${authentik_stage_prompt.recovery_prompt_stage.id}";
        order = 30;
      };
      recovery_user_write = {
        target = "\${authentik_flow.recovery_password_flow.uuid}";
        stage = "\${authentik_stage_user_write.recovery_write_user.id}";
        order = 50;
      };
      recovery_user_login = {
        target = "\${authentik_flow.recovery_password_flow.uuid}";
        stage = "\${authentik_stage_user_login.user_login_stage.id}";
        order = 50;
      };
    };
    authentik_stage_identification.recovery_identification_stage = {
      name = "recovery-identification-stage";
      user_fields = [ "username" "email" ];
    };
    authentik_policy_binding.recovery_policy = {
      target = "\${authentik_flow.recovery_password_flow.uuid}";
      policy = "\${authentik_policy_expression.skip_if_restored.id}";
      order = 0;
      };
  };
}
