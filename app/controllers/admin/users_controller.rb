class Admin::UsersController < Admin::CrudController
  def actions_with_resource
    super + [:impersonate]
  end

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
    @resources = model.where("first_name ilike :q or last_name ilike :q",
                             q: "%#{params[:q]}%").order("first_name, last_name").page(params[:page])
    render json: {
      results:    @resources.map { |r| { id: r.id, text: r.full_name } },
      pagination: {
        more: @resources.next_page.present?
      }
    }
  end

  def scope
    super.includes(:roles)
  end

  def name_attribute
    :full_name
  end

  def impersonate
    session[:impersonator_id] = current_user.id
    bypass_sign_in @resource
    redirect_to "/", flash: { success: "You have successfully impersonated #{current_user.full_name}" }
  end
end
