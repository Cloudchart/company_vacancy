class AddStatusToVacanciesAndVacancyResponses < ActiveRecord::Migration
  def up
    add_column :vacancies, :status, :string, null: false
    add_column :vacancy_responses, :status, :string, null: false

    add_index :vacancies, :status
    add_index :vacancy_responses, :status

    Vacancy.update_all(status: :draft)
    VacancyResponse.update_all(status: :pending)
  end

  def down
    remove_index :vacancies, :status
    remove_index :vacancy_responses, :status

    remove_column :vacancies, :status
    remove_column :vacancy_responses, :status
  end
end
