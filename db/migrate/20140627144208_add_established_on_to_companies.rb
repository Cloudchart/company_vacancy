class AddEstablishedOnToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :established_on, :date
  end
end
