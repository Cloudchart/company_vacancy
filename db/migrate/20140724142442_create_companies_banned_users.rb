class CreateCompaniesBannedUsers < ActiveRecord::Migration
  def change
    create_table :companies_banned_users, id: false do |t|
      t.string :company_id, limit: 36, null: false
      t.string :user_id, limit: 36, null: false
    end
    
    add_index :companies_banned_users, [:company_id, :user_id], unique: true
  end
end
