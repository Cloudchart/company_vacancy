class AddSettingsToVacancies < ActiveRecord::Migration
  def change
    add_column :vacancies, :settings, :text
  end
end
