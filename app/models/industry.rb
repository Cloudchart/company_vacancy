class Industry < ActiveRecord::Base
  include Uuidable

  acts_as_nested_set parent_column: :parent_uuid, primary_column: :uuid

  has_and_belongs_to_many :companies

  validates :name, presence: true

  rails_admin do

    list do
      include_fields :name, :parent, :created_at, :updated_at
    end

    edit do
      include_fields :name, :parent, :children
    end

    show do
      include_fields :name, :children
    end

  end  

end
