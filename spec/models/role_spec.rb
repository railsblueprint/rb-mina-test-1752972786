require "rails_helper"

RSpec.describe Role, type: :model do
  include Shoulda::Matchers::ActiveModel
  include Shoulda::Matchers::ActiveRecord

  it { is_expected.to have_db_column(:name).of_type(:string) }

  describe "associations" do
    it { is_expected.to belong_to(:resource).optional(true) }
  end
end
