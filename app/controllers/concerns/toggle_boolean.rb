module ToggleBoolean
  extend ActiveSupport::Concern

  included do
    def self.toggle_boolean *fields
      fields.each do |field|
        define_method :"toggle_#{field}" do
          toggle_boolean_action(field)
        end
      end
    end
  end

  def toggle_boolean_action field
    load_resource
    @resource.update!(field => !@resource.send(field))

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace("#{@resource.id}_#{field}", partial: "shared/toggle_bool",
                                                                              locals:  { field: field })
      }
      format.html { redirect_to @resource }
    end
  end
end
