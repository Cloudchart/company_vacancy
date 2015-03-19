class CreateOauthProviders < ActiveRecord::Migration
  def up
    create_table :oauth_providers, id: false do |t|
      t.string    :uuid,      limit: 36
      t.string    :user_id,   limit: 36
      t.string    :provider
      t.string    :uid
      t.text      :info
      t.text      :credentials
      t.timestamps
    end

    add_index :oauth_providers, :user_id
    execute 'ALTER TABLE oauth_providers ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :user_id
    drop_table :oauth_providers
  end
end
