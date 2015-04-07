class Role < ActiveRecord::Base
  include Uuidable
  include Admin::Role

  belongs_to :user
  belongs_to :owner, polymorphic: true

  belongs_to :pinboard, foreign_key: :owner_id, foreign_type: Pinboard

  validates :value, inclusion: { in: Company::INVITABLE_ROLES.map(&:to_s) }, on: :update, if: -> { owner_type == 'Company' }
  validates :value, inclusion: { in: Pinboard::INVITABLE_ROLES.map(&:to_s) }, on: :update, if: -> { owner_type == 'Pinboard' }
  validates :value, inclusion: { in: Cloudchart::ROLES.map(&:to_s) }, on: :create, if: -> { owner_type.blank? }
  validate :acceptance_of_invite, on: :create

private

  def acceptance_of_invite
    if owner_type =~ /Company|Pinboard/ && (user.roles.map(&:owner_id).include?(owner_id) || owner.try(:user_id) == user_id)
      errors.add(:base, I18n.t('errors.roles.acceptance', name: owner_type))
    end
  end

end
