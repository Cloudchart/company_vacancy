class Person < ActiveRecord::Base
  include Uuidable
  include Tire::Model::Search
  include Tire::Model::Callbacks

  belongs_to :user
  belongs_to :company

  validates :name, presence: true
  
end
