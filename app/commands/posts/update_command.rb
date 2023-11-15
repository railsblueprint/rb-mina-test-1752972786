module Posts
  class UpdateCommand < Crud::UpdateCommand
    include Attributes
    detect_adapter
  end
end
