class Admin::Controller < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_role
  # before_action :check_permissions

  layout lambda {
    turbo_frame_request? && !turbo_frame_breakout ? "turbo_rails/frame" : "application"
  }

  before_action do
    @page_title = t(".page_title")
    breadcrumb "<i class='bi bi-house-fill'></i>Home", :root_path
    breadcrumb "Admin", :admin_root_path
  end

  private

  def check_admin_role
    return if current_user.admin?

    flash[:alert] = "You cannot access this page"
    redirect_to "/"
  end
end
