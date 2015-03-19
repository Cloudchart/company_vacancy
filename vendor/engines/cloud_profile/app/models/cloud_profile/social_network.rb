module CloudProfile
  class SocialNetwork < ActiveRecord::Base

    include Uuidable

    serialize :data, OpenStruct
    #delegate  :first_name, :last_name, :email, :link, :picture, to: :data

    belongs_to :user, inverse_of: :social_networks

  end
end
