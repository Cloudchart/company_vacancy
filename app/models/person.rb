class Person < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  belongs_to :company

  validates :name, presence: true

  searchable do
    text :name, :email
  end
  
end
