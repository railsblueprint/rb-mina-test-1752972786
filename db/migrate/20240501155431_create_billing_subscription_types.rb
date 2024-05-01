class CreateBillingSubscriptionTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :billing_subscription_types, id: :uuid do |t|
      t.string :name, null: false
      t.string :description
      t.string :reference
      t.integer :periodicity, default: 2, null: false
      t.decimal :price, null: false, precision: 10, scale: 2
      t.boolean :active, default: true, null: false
      t.string :stripe_id

      t.timestamps
    end
  end
end
