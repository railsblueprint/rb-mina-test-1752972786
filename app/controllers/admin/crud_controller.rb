class Admin::CrudController < Admin::Controller
  include CrudBase
  include CrudAuthorization
  include Breadcrumbs

  def paginate(collection)
    [nil, collection.page(params[:page])]
  end

  def actions_with_resource
    base_actions_with_resource + [:logs]
  end

  def logs
    breadcrumb t("actions.logs"), { action: :logs }
    @pagy, @resources = pagy(@resource.user_logs.order(created_at: :desc))
    render "admin/user_logs/index"
  end

  def filter_boolean field
    return unless params[field].present?

    @resources = if params[field] == "nil"
                   @resources.where(field => nil)
                 else
                   @resources.where(field => params[field].to_b)
                 end
  end

  private

  def context
    {
      id:           @resource&.id,
      current_user:
    }
  end
end
