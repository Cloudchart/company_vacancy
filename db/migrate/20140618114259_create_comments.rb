class CreateComments < ActiveRecord::Migration
  def up
    create_table :comments, id: false do |t|
      t.string :uuid, limit: 36
      t.text :content
      t.string :user_id, limit: 36, null: false
      t.string :commentable_id, limit: 36, null: false
      t.string :commentable_type, null: false

      t.timestamps
    end

    add_index :comments, :user_id
    add_index :comments, [:commentable_id, :commentable_type]
    execute 'ALTER TABLE comments ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :comments, :user_id
    remove_index :comments, [:commentable_id, :commentable_type]
    drop_table :comments
  end
end
