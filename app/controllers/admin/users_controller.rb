class Admin::UsersController < Admin::CrudController
  # rubocop:disable Metrics/AbcSize, Style/GuardClause
  def filter_resources
    @resources = @resources.with_role(params[:role]) if params[:role].present? && (params[:role][0] != "_")
    if params[:q].present?
      @resources = @resources.where("first_name ilike :q or last_name ilike :q " \
                                    "or email ilike :q or users.id::text = :id", q: "%#{params[:q]}%", id: params[:q])
    end
  end
  # rubocop:enable Metrics/AbcSize, Style/GuardClause

  def lookup
    @resources = model.all.where("first_name ilike :q or last_name ilike :q",
                                 q: "%#{params[:q]}%").order("first_name, last_name").page(params[:page])
    render json: {
      results:    @resources.map { |r| { id: r.id, text: r.full_name } },
      pagination: {
        more: @resources.next_page.present?
      }
    }
  end

  def model
    User
  end

  def scope
    super.includes(:roles)
  end

  def title
    :full_name
  end

  def become
    @user = User.find(params[:id])
    bypass_sign_in @user
    redirect_to "/"
  end

  private

  def safe_params
    params.require(:user).permit(
      :role, :first_name, :last_name, :email, :about, :job, :company,
      :address, :country,
      :twitter_profile, :facebook_profile, :linkedin_profile, :instagram_profile,
      :password, :password_confirmation, role_ids: []
    )
  end
end
