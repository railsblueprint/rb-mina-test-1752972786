class AdminFilteredSearchComponent < ViewComponent::Base
  attr_accessor :fields

  def initialize(fields: [])
    @fields = fields
  end
end
