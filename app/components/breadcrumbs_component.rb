class BreadcrumbsComponent < ViewComponent::Base
  include Turbo::FramesHelper
  include Loaf::ViewExtensions

  attr_accessor :_breadcrumbs

  def initialize(_breadcrumbs)
    @_breadcrumbs = _breadcrumbs
  end
end
