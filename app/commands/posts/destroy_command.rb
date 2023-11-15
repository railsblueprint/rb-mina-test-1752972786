module Posts
  class DestroyCommand < Crud::DestroyCommand
    adapter Post
  end
end
