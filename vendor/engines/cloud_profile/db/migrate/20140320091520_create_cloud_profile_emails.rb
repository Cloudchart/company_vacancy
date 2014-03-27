class CreateCloudProfileEmails < ActiveRecord::Migration
  def up
    create_table :cloud_profile_emails, id: false do |t|
      t.string  :uuid,    limit: 36, null: false
      t.string  :user_id, limit: 36
      t.string  :address
      t.timestamps
    end

    execute 'ALTER TABLE cloud_profile_emails ADD PRIMARY KEY (uuid);'
    add_index :cloud_profile_emails, :address
  end
  
  def down
    drop_table :cloud_profile_emails
  end
end
