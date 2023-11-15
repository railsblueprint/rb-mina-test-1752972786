class Admin::SettingsController < Admin::CrudController
  include Breadcrumbs
  before_action :set_editable

  def prepend_breadcrumbs
    breadcrumb t("admin.nav.configuration"), ""
    @sets = Setting.where(type: :set)
  end

  def name_attribute
    :description
  end

  def set_editable
    @editable = false

    return unless Rails.env.development?
    return unless current_user.has_role?(:superadmin)
    return if Setting.disable_settings_editor

    @editable = true
  end

  def index
    super
    @unsaved = Setting.unsaved.any? if Rails.env.development?
  end

  def no_show_action? = true

  def mass_update
    Setting.update(mass_update_params.keys, mass_update_params.values) if params[:settings].present?
    flash[:success] = t("messages.successfully_updated")
    redirect_to action: :index, status: :see_other
  end

  def mass_update_params
    params.permit![:settings]
  end

  def safe_params
    params.require(:setting).permit(:alias, :description, :type, :value, :set)
  end
end
