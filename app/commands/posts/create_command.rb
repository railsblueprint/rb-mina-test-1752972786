module Posts
  class CreateCommand < Crud::CreateCommand
    include Attributes
  end
end
