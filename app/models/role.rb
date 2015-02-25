class Role < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  belongs_to :owner, polymorphic: true

  validates :value, inclusion: { in: Company::INVITABLE_ROLES.map(&:to_s) }, on: :update, if: -> { owner_type == 'Company' }
  validates :value, inclusion: { in: Pinboard::INVITABLE_ROLES.map(&:to_s) }, on: :update, if: -> { owner_type == 'Pinboard' }
  validates :value, inclusion: { in: Cloudchart::ROLES.map(&:to_s) }, on: :create, if: -> { owner_type.blank? }
  validate :acceptance_of_company_invite, on: :create

private

  def acceptance_of_company_invite
    if owner_type == 'Company' && user.roles.map(&:owner_id).include?(owner_id)
      errors.add(:base, I18n.t('errors.roles.acceptance'))
    end
  end

end
