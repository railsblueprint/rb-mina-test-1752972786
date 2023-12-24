RSpec.describe 'Visit homepage', type: :system do
  scenario 'simple visit' do
    visit root_path
    expect(page).to have_content('Welcome to Rails Blueprint')
  end

  scenario 'search' do
    visit root_path
    fill_in 'q', with: "test\n"

    find(".controller-posts.action-index")
    expect(page).to have_content("Search results for 'test'")
  end
end
