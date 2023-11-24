class Admin::DashboardController < Admin::Controller
  def show
    _breadcrumbs.delete_at(_breadcrumbs.length - 1)
    breadcrumb "Dashboard", :admin_root_path
    @page_title = "Dashboard"
  end

  def search
    breadcrumb "Global search", url_for
    return unless params[:q].present?

    @results = PgSearch.multisearch(params[:q]).includes(:searchable).page(params[:page])
  end
end
