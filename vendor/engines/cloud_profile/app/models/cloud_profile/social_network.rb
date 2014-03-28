module CloudProfile
  class SocialNetwork < ActiveRecord::Base
    
    include Uuidable
    
    serialize :data

    belongs_to :user, inverse_of: :social_networks
    
    
    def email
      @email ||= case name.to_sym
        when :facebook
          data['email']
      end
    end
    
    
    def first_name
      @first_name ||= case name.to_sym
        when :facebook
          data['first_name']
      end
    end
    

    def last_name
      @last_name ||= case name.to_sym
        when :facebook
          data['last_name']
      end
    end
    

  end
end
