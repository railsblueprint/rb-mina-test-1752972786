require "rails_helper"

RSpec.describe "Admin Settings", type: :request do
  include_examples "admin crud controller", {resource: :settings, model: Setting, prefix: "config"}
end