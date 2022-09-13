module LocaleMethods
  def set_locale
    I18n.locale =
      session_locale ||
        locale_from_profile ||
        locale_from_accept_language_header ||
        default_locale ||
        I18n.default_locale
  end

  def locale_from_accept_language_header
    validated_locale(request.env["HTTP_ACCEPT_LANGUAGE"]&.scan(/^[a-z]{2}/)&.first)
  end

  def session_locale
    validated_locale(session[:locale])
  end

  def locale_from_profile
    return unless current_user

    validated_locale(current_user.locale)
  end

  def dafault_locale
    validated_locale(Setting.default_local)
  end

  def validated_locale(locale)
    locale = locale&.to_sym
    return locale if I18n.available_locales.include?(locale)
  end
end
