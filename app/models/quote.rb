class Quote < ActiveRecord::Base
  include Uuidable
  
  belongs_to :owner, polymorphic: true
  has_one :person

  validates :text, presence: true
end
