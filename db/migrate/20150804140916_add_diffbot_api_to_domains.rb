class AddDiffbotApiToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :diffbot_api, :integer, default: 0
  end
end
