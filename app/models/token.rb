class Token < ActiveRecord::Base
  include Uuidable

  serialize :data

  belongs_to :tokenable, polymorphic: true
  
end
