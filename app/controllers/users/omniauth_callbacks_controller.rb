class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: [:google_oauth2, :github, :facebook, :twitter, :linkedin]

  def google_oauth2
    handle_auth "Google"
  end

  def github
    handle_auth "GitHub"
  end

  def facebook
    handle_auth "Facebook"
  end

  def twitter
    handle_auth "Twitter"
  end

  def linkedin
    handle_auth "LinkedIn"
  end

  def failure
    redirect_to new_user_session_path,
                alert: t("devise.omniauth_callbacks.failure", kind:   params[:strategy]&.capitalize,
                                                              reason: params[:message])
  end

  private

  # rubocop:disable Metrics/AbcSize
  def handle_auth(provider_name)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
    else
      session["devise.provider_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end
  # rubocop:enable Metrics/AbcSize
end
