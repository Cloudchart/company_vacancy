class AddLogotypeUidToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :logotype_uid, :string
  end
end
