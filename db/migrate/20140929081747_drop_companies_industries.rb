class DropCompaniesIndustries < ActiveRecord::Migration
  def up
    remove_index :companies_industries, [:company_id, :industry_id]
    drop_table :companies_industries
  end

  def down
    create_table :companies_industries, id: false do |t|
      t.string :company_id, limit: 36, null: false
      t.string :industry_id, limit: 36, null: false
    end

    add_index :companies_industries, [:company_id, :industry_id], unique: true
  end
end
