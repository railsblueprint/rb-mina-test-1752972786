class Admin::DesignSystem::TablesController < Admin::Controller
  before_action do
    breadcrumb t("admin.nav.design_system.design_system"), ""
    breadcrumb "Tables", ""
    breadcrumb t("admin.nav.design_system.tables_#{params[:action]}"), url_for
  end
end
