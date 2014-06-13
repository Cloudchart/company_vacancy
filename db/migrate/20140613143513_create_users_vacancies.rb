class CreateUsersVacancies < ActiveRecord::Migration
  def change
    create_table :users_vacancies, id: false do |t|
      t.string :user_id, limit: 36, null: false
      t.string :vacancy_id, limit: 36, null: false
    end

    add_index :users_vacancies, [:user_id, :vacancy_id], unique: true
  end
end
