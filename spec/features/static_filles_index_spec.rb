require 'rails_helper'

RSpec.describe 'Visit homepage', type: :feature do
  scenario 'simple visit' do
    visit root_path
    expect(page).to have_content('Welcome to Rails Blueprint')
  end
end
