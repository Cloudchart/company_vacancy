class CompanyAccessRight < ActiveRecord::Base
  include Uuidable

  # ROLES = [:owner, :editor, :trusted_reader, :public_reader]

  belongs_to :user
  belongs_to :company

end
