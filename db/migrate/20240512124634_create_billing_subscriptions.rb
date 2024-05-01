class CreateBillingSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :billing_subscriptions, id: :uuid do |t|
      t.references :user, null: false, type: :uuid, foreign_key: true
      t.references :subscription_type, null: false, type: :uuid, foreign_key: {to_table: :billing_subscription_types}
      t.date :start_date, null: false
      t.date :renew_date, null: false
      t.boolean :cancelled, null: false, default: false
      t.string :stripe_id
      t.timestamps
    end
  end
end
