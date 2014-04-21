# This migration comes from cloud_profile (originally 20140326110531)
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

    execute 'ALTER TABLE cloud_profile_social_networks ADD PRIMARY KEY (uuid);'
  end
  
  def down
    drop_table :cloud_profile_social_networks
  end
end
