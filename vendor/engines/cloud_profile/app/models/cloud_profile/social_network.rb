module CloudProfile
  class SocialNetwork < ActiveRecord::Base
    
    include Uuidable
    
    serialize :data

    belongs_to :user, inverse_of: :social_networks
    
  end
end
