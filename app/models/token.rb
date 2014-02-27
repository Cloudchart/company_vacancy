class Token < ActiveRecord::Base
  include Uuidable

  serialize :data

  belongs_to :owner, polymorphic: true
  
end
