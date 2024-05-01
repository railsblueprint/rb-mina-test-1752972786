class Admin::Billing::SubscriptionTypesController < Admin::CrudController
  include ToggleBoolean
  toggle_boolean :active, :show_in_sidebar

  def prepend_breadcrumbs
    breadcrumb t("admin.nav.billing"), ""
  end

  def filter_resources
    @resources = @resources.search(params[:q]) if params[:q].present?
    filter_boolean :active
    filter_boolean :show_in_sidebar
  end

  def module_name
    "Billing::SubscriptionTypes"
  end
end
