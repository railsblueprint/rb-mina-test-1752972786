class Admin::PostsController < Admin::CrudController
  # before_action {check_role :superadmin}

  # rubocop:disable Style/GuardClause
  def filter_resources
    @resources = @resources.search(params[:q]) if params[:q].present?

    if params[:user_id].present?
      @resources = @resources.where(user_id: params[:user_id])
      @selected_user = User.find(params[:user_id])
    end
  end
  # rubocop:enable Style/GuardClause

  def scope
    model.includes(:user)
  end

  def model
    Post
  end

  def title
    :title
  end

  private

  def safe_params
    params.require(:post).permit(:title, :body, :user_id)
  end
end
