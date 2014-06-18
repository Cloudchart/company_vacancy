class AddAuthorIdToVacancies < ActiveRecord::Migration
  def change
    add_column :vacancies, :author_id, :string, limit: 36, null: false
  end
end
