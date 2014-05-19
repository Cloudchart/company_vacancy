class CreateCloudProfileSocialNetworks < ActiveRecord::Migration
  def up
    create_table :cloud_profile_social_networks, id: false do |t|
      t.string    :uuid,    limit: 36,  null: false
      t.string    :user_id, limit: 36
      t.string    :name,                null: false
      t.string    :provider_id,         null: false
      t.text      :access_token,        null: false
      t.text      :data
      t.boolean   :is_visible, default: false
      t.datetime  :expires_at

      t.timestamps
    end

    add_index :cloud_profile_social_networks, :user_id
    add_index :cloud_profile_social_networks, :provider_id
    execute 'ALTER TABLE cloud_profile_social_networks ADD PRIMARY KEY (uuid);'
  end
  
  def down
    remove_index :cloud_profile_social_networks, :user_id
    remove_index :cloud_profile_social_networks, :provider_id
    drop_table :cloud_profile_social_networks
  end
end
