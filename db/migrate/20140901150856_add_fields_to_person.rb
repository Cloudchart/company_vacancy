class AddFieldsToPerson < ActiveRecord::Migration
  def change
    add_column :people, :hired_on, :date
    add_column :people, :fired_on, :date
    add_column :people, :skype, :string
    add_column :people, :int_phone, :string
    add_column :people, :bio, :text
    add_column :people, :birthday, :date
    add_column :people, :salary, :decimal, precision: 10, scale: 2, default: 0
  end
end
