module Posts
  class CreateCommand < Crud::CreateCommand
    include Attributes
    detect_adapter
  end
end
