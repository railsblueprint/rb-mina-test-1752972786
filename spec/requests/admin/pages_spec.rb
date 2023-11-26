require "rails_helper"

RSpec.describe "Admin Pages", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:moderator) { create(:user, :moderator) }

  include_examples "admin crud controller", "pages", Page
end