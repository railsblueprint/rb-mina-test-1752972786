class LanguageSelectorComponent < ViewComponentReflex::Component
  include FormsHelper

  def initialize
    super
    @locale = I18n.locale
    @available_locales = Setting.available_locales
  end

  def set
    prevent_refresh!

    @locale = element.dataset["locale"]
    session[:locale] = @locale

    refresh_all!
  end
end
