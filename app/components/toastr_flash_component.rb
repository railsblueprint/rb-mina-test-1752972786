class ToastrFlashComponent < ViewComponent::Base
  attr_accessor :append

  def initialize(append: false)
    super
    @append = append
  end
end
