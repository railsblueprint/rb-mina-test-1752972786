class AddOauthToUsers < ActiveRecord::Migration[8.0]
  def up
    create_table :user_identities, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :oauth_token
      t.datetime :oauth_expires_at
      t.string :oauth_refresh_token

      t.timestamps
    end
    
    add_index :user_identities, [:provider, :uid], unique: true
    add_index :user_identities, [:user_id, :provider], unique: true
  end
  
  def down
    # Handle rollback for the old version that added columns to users
    if column_exists?(:users, :provider)
      remove_index :users, [:provider, :uid] if index_exists?(:users, [:provider, :uid])
      remove_index :users, :provider if index_exists?(:users, :provider)
      
      remove_column :users, :provider
      remove_column :users, :uid
      remove_column :users, :oauth_token
      remove_column :users, :oauth_expires_at
      remove_column :users, :oauth_refresh_token
    end
    
    # Handle rollback for the new version that creates user_identities
    drop_table :user_identities if table_exists?(:user_identities)
  end
end
