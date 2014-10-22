class RemoveSections < ActiveRecord::Migration
  def change
    remove_column :companies, :sections, :text
    remove_column :vacancies, :sections, :text
    remove_column :events, :sections, :text
    remove_column :blocks, :section, :string, null: false
  end
end
