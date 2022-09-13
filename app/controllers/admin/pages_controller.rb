class Admin::PagesController < Admin::CrudController
  include ToggleBoolean
  toggle_boolean :active, :show_in_sidebar

  # before_action {check_role :superadmin}

  def filter_resources
    @resources = @resources.search(params[:q]) if params[:q].present?
    filter_boolean :active
    filter_boolean :show_in_sidebar
  end

  def model
    Page
  end

  def title
    :title
  end

  private

  def safe_params
    params.require(:page).permit(
      :url, :title, :body,
      :seo_title, :seo_description, :seo_keywords,
      :show_in_sidebar, :active, :icon
    )
  end
end
