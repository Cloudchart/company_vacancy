class OauthProvider < ActiveRecord::Base

  include Uuidable

  serialize :info,        OpenStruct
  serialize :credentials, OpenStruct

  belongs_to :user, inverse_of: :oauth_providers

end
