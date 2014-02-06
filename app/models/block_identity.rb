class BlockIdentity < ActiveRecord::Base

  include Uuidable  
  
  belongs_to :block
  
  belongs_to :identity, polymorphic: true
  
end
