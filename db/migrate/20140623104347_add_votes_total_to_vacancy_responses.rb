class AddVotesTotalToVacancyResponses < ActiveRecord::Migration
  def change
    add_column :vacancy_responses, :votes_total, :integer
  end
end
