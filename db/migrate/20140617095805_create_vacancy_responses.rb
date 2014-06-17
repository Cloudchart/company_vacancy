class CreateVacancyResponses < ActiveRecord::Migration
  def up
    create_table :vacancy_responses, id: false do |t|
      t.string :uuid, limit: 36
      t.text :content
      t.string :user_id, limit: 36, null: false
      t.string :vacancy_id, limit: 36, null: false
      t.timestamps
    end

    add_index :vacancy_responses, [:user_id, :vacancy_id], unique: true
    execute 'ALTER TABLE vacancy_responses ADD PRIMARY KEY (uuid);'
  end

  def down
    remove_index :vacancy_responses, [:user_id, :vacancy_id]
    drop_table :vacancy_responses
  end
end
