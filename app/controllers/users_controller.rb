class UsersController < ApplicationController
  def show
    @resource = params[:id].present? ? User.find(params[:id]) : current_user
    render_404 unless @resource
  end

  def edit
    @resource = current_user
    @password_command = ChangePasswordCommand.new

    render :form
  end

  def update
    @resource = current_user

    @resource.update(safe_params)
    respond_to do |format|
      format.json {
        head :ok
      }
      format.html {
        flash[:success] = t("messages.successfully_updated")
        url = params[:back_url].presence || { action: :edit }
        redirect_to url, status: :see_other
      }
    end
  end

  # rubocop:disable Metrics/AbcSize
  # TODO: how i can fix it?
  def password
    ChangePasswordCommand.call_for(params) do |command|
      @password_command = command
      command.on :ok do
        respond_to do |format|
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace("frame_new_contact_us_command", partial: "success")
          }
          format.html         { redirect_to action: :edit }
        end
      end
      command.on :invalid, :abort do
        respond_to do |format|
          format.turbo_stream {
            render turbo_stream: turbo_stream.replace("frame_new_contact_us_command", partial: "form")
          }
          format.html { render "form" }
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def safe_params
    params.require(:user).permit(
      :role, :first_name, :last_name, :email, :about, :job, :company,
      :address, :country, :phone,
      :twitter_profile, :facebook_profile, :linkedin_profile, :instagram_profile,
      :current_password, :password, :password_confirmation, role_ids: []
    )
  end

  def disavow
    impersonator = User.find_by_id(session[:impersonator_id])
    if impersonator.nil?
      session[:impersonator_id] = nil
      redirect_to "/", flash: { info: "You did not have impersonation" }
    else
      bypass_sign_in impersonator
      session[:impersonator_id] = nil
      redirect_to "/", flash: { success: "You have been disavowed from impersonation" }
    end
  end
end
