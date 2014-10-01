class Picture < ActiveRecord::Base
  include Uuidable
  
  dragonfly_accessor :image

  has_one :block_identity, as: :identity, inverse_of: :identity

end
