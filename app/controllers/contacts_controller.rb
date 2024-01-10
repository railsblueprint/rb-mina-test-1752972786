class ContactsController < ApplicationController
  def new
    @command = ContactUsCommand.new(name: current_user&.full_name, email: current_user&.email, current_user:)
  end

  def create
    ContactUsCommand.call_for(params, current_user:) do |command|
      @command = command
      command.on :ok do
        render "success"
      end
      command.on :invalid, :abort do |errors|
        flash.now[:error] = {
          message: "Failed to send your message. Please try again.",
          details: errors.full_messages
        }
        render "new"
      end
    end
  end
end
