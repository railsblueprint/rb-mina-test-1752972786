class Admin::PostsController < Admin::CrudController
  # rubocop:disable Style/GuardClause
  def filter_resources
    @resources = @resources.search(params[:q]) if params[:q].present?

    if params[:user_id].present?
      @resources = @resources.where(user_id: params[:user_id])
      @selected_user = User.find(params[:user_id])
    end
  end
  # rubocop:enable Style/GuardClaus

  def scope
    model.includes(:user)
  end

  def name_attribute
    :title
  end
end
