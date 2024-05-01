class UsersAddStripeId < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :stripe_id, :string, null: true
    add_index :users, :stripe_id
  end
end
