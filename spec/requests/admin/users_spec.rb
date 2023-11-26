require "rails_helper"

RSpec.describe "Admin Users", type: :request do
  options = {resource: :users, model: User, has_filters: true}
  include_examples "admin crud controller", options
  include_examples "admin crud controller paginated index", options
  include_examples "admin crud controller show resource", options
end