class Company
  class AccessRight < ActiveRecord::Base
    include Uuidable

    belongs_to :user
    belongs_to :company

  end
end
