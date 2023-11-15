class InfiniteLoaderComponent < ViewComponent::Base
  attr_reader :visible
  def initialize(visible: false)
    @visible = visible
  end
end
