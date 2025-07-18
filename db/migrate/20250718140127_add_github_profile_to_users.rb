class AddGithubProfileToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :github_profile, :string
  end
end
