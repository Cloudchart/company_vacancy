class CreateVacancyReviewers < ActiveRecord::Migration
  def change
    create_table :vacancy_reviewers, id: false do |t|
      t.string :person_id, limit: 36, null: false
      t.string :vacancy_id, limit: 36, null: false
    end

    add_index :vacancy_reviewers, [:person_id, :vacancy_id], unique: true
  end
end
