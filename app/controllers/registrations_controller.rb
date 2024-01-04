class RegistrationsController < Devise::RegistrationsController
  # layout "devise"

  def new
    build_resource
    yield resource if block_given?
    respond_with resource
  end

  def build_resource(_hash={})
    self.resource = Users::RegisterCommand.new
  end

  def create
    Users::RegisterCommand.call_for(params) do |command|
      command.on(:ok) do |resource|
        successfuly_created(resource)
      end
      command.on(:invalid, :abort) do |errors|
        self.resource = command
        flash.now[:error] = {
          message: I18n.t("admin.common.failed_to_create_item", record: :user),
          details: errors.full_messages
        }
        respond_with resource
      end
    end
  end

  def successfuly_created(resource)
    if resource.active_for_authentication?
      set_flash_message! :notice, :signed_up
      sign_up(resource_name, resource)
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
      expire_data_after_sign_in!
      respond_with resource, location: after_inactive_sign_up_path_for(resource)
    end
  end
end
