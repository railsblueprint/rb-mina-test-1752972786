class Admin::Billing::SubscriptionsController < Admin::CrudController
  include ToggleBoolean

  def prepend_breadcrumbs
    breadcrumb t("admin.nav.billing"), ""
  end

  def filter_resources
    @resources = @resources.search(params[:q]) if params[:q].present?
    filter_boolean :cancelled
  end

  def module_name
    "Billing::Subscriptions"
  end
end
