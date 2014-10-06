class Role < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  belongs_to :owner, polymorphic: true

  validate :acceptance_of_company_invite

private

  def acceptance_of_company_invite
    if owner_type == 'Company' && user.roles.pluck(:owner_id).include?(owner_id)
      errors.add(:base, I18n.t('errors.roles.acceptance'))
    end
  end

end
