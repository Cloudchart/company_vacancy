class Friend < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  
end
