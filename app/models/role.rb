class Role < ActiveRecord::Base
  include Uuidable
  include Admin::Role

  before_save :check_value
  after_create :clean_user_owner_associations, if: -> { owner_type == 'Company' }

  belongs_to :user
  belongs_to :author, class_name: User.name
  belongs_to :owner, polymorphic: true

  belongs_to :pinboard, foreign_key: :owner_id, foreign_type: Pinboard
  belongs_to :company,  foreign_key: :owner_id, foreign_type: Company

  validates :value, inclusion: { in: Company::INVITABLE_ROLES.map(&:to_s) }, on: :update, if: -> { owner_type == 'Company' }
  validates :value, inclusion: { in: Pinboard::INVITABLE_ROLES.map(&:to_s) }, on: :update, if: -> { owner_type == 'Pinboard' }
  validates :value, inclusion: { in: Cloudchart::ROLES.map(&:to_s) }, on: :create, if: -> { owner_type.blank? }

  validate :acceptance_of_invite, on: :create

  def accept!
    update!(value: pending_value, pending_value: nil)
  end

  def should_skip_pending_role!
    @should_skip_pending_role = true
  end

  def should_skip_pending_role?
    !!@should_skip_pending_role
  end

private

  def check_value
    return unless owner.present?

    if new_record? && !should_skip_pending_role?
      self.pending_value  = self.value
      self.value          = owner.class::ACCESS_ROLE
    else
      if pending_value.present?
        self.pending_value  = value
        self.value          = value_was
      end
    end
  end

  def clean_user_owner_associations
    user.favorites.find_by(favoritable_id: owner_id).try(:delete)
    user.company_invite_tokens.select { |token| token.owner_id == owner_id }.try(:first).try(:delete)
  end

  def acceptance_of_invite
    if user.blank?
      errors.add(:base, I18n.t('errors.roles.user_blank'))
    elsif owner_type =~ /Company|Pinboard/ && (user.roles.map(&:owner_id).include?(owner_id) || owner.try(:user_id) == user_id)
      errors.add(:base, I18n.t('errors.roles.acceptance', name: owner_type))
    end
  end

end
