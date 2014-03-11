class CreateFeatures < ActiveRecord::Migration
  def up
    create_table :features, id: false do |t|
      t.string :uuid, limit: 36
      t.string :name, null: false
      t.text :description
      t.integer :votes_total

      t.timestamps
    end
  end

  def down
    drop_table :features
  end
end
