class CreateInterviews < ActiveRecord::Migration
  def up
    create_table :interviews, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name, null: false
      t.string :email
      t.string :company_name
      t.string :ref_name
      t.string :ref_email
      t.text :whosaid
      t.boolean :is_accepted, default: false
      t.string :slug, null: false

      t.timestamps
    end

    execute 'ALTER TABLE interviews ADD PRIMARY KEY (uuid);'
  end

  def down
    drop_table :interviews
  end
end
