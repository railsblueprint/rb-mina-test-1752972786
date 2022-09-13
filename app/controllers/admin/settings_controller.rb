class Admin::SettingsController < Admin::Controller
  # before_action {check_role :superadmin}
  before_action :set_editable

  before_action do
    breadcrumb t("admin.nav.configuration"), ""
    breadcrumb t("admin.nav.settings"), action: :index
    @sets = Setting.where(type: :set)
  end

  def set_editable
    @editable = false

    return unless Rails.env.development?
    return unless current_user.has_role?(:superadmin)
    return if Setting.disable_settings_editor

    @editable = true
  end

  def index
    @resources = Setting.all
    @unsaved = Setting.unsaved.any? if Rails.env.development?
  end

  def new
    breadcrumb I18n.t("actions.new"), action: :new
    @resource = Setting.new
    render "form"
  end

  def create
    @resource = Setting.new
    @resource.update safe_params.merge(not_migrated: true)

    if @resource.valid?
      flash[:success] = I18n.t("messages.successfully_created")
      redirect_to [:edit, :admin, @resource], status: :see_other
    else
      breadcrumb t("actions.new"), action: :new
      render "form", status: :unprocessable_entity
    end
  end

  def edit
    @resource = Setting.find(params[:id])
    breadcrumb @resource.alias, action: :edit
    render "form"
  end

  def update
    @resource = Setting.find(params[:id])
    @resource.update safe_params
    breadcrumb @resource.alias, [:new, :admin, :setting]

    if @resource.valid?
      flash[:success] = I18n.t("messages.successfully_updated")
      redirect_to [:edit, :admin, @resource], status: :see_other
    else
      render "form", status: :unprocessable_entity
    end
  end

  def destroy
    @resource = Setting.find(params[:id])
    @resource.update(deleted_at: Time.now)
    flash[:success] = t("messages.successfully_deleted")
    redirect_to action: :index, status: :see_other
  end

  def mass_update
    Setting.update(params[:settings].keys, params[:settings].values) if params[:settings].present?
    flash[:success] = t("messages.successfully_updated")
    redirect_to action: :index, status: :see_other
  end

  def safe_params
    params.require(:setting).permit(:alias, :description, :type, :value, :set)
  end
end
