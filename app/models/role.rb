class Role < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  belongs_to :owner, polymorphic: true

  validates :value, inclusion: { in: Company::INVITABLE_ROLES.map(&:to_s) }, on: :update, if: -> { owner_type == 'Company' }
  validate :acceptance_of_company_invite, on: :create

private

  def acceptance_of_company_invite
    if owner_type == 'Company' && user.roles.pluck(:owner_id).include?(owner_id)
      errors.add(:base, I18n.t('errors.roles.acceptance'))
    end
  end

end
