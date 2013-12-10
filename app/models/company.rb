class Company < ActiveRecord::Base
  include Extensions::UUID
  mount_uploader :logo, LogoUploader
end
