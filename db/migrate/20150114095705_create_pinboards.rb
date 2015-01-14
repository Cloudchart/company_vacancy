class CreatePinboards < ActiveRecord::Migration
  def up
    create_table :pinboards, id: false do |t|
      t.string  :uuid,      limit: 36,  null: false
      t.string  :title,                 null: false
      t.string  :user_id,   limit: 36,  null: false
      t.integer :position,              default: 0
      t.timestamps
    end

    add_index   :pinboards, :user_id
    execute     'ALTER TABLE pinboards ADD PRIMARY KEY (uuid);'
  end
  
  def down
    remove_index  :pinboards, :user_id
    drop_table    :pinboards
  end
end
