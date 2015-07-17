class AddSuggestionRightsToPinboards < ActiveRecord::Migration
  def change
    add_column :pinboards, :suggestion_rights, :integer, default: 0
  end
end
