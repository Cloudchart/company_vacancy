class Role < ActiveRecord::Base
  include Uuidable
  include Admin::Role

  before_save :check_value
  after_create :clean_user_owner_associations, if: -> { owner_type == 'Company' }

  has_should_markers :should_skip_pending_role
  nilify_blanks only: :pending_value

  belongs_to :user
  belongs_to :author, class_name: 'User'
  belongs_to :owner, polymorphic: true

  belongs_to :pinboard, foreign_key: :owner_id, foreign_type: 'Pinboard'
  belongs_to :company,  foreign_key: :owner_id, foreign_type: 'Company'

  validates :value, inclusion: { in: Cloudchart::COMPANY_INVITABLE_ROLES.map(&:to_s) }, on: :update, if: -> { owner_type == 'Company' }
  validates :value, inclusion: { in: Cloudchart::PINBOARD_INVITABLE_ROLES.map(&:to_s) }, on: :update, if: -> { owner_type == 'Pinboard' }
  validates :value, inclusion: { in: Cloudchart::ROLES.map(&:to_s) }, on: :create, if: -> { owner_type.blank? }

  validate :acceptance_of_invite, on: :create

  scope :invites, -> { where.not(pending_value: nil) }
  scope :pinboard_invites, -> { invites.where(owner_type: 'Pinboard') }

  scope :ready_for_broadcast, -> id, type, start_time, end_time do
    send(:"#{type}_invites").where {
      created_at.gteq(start_time) &
      created_at.lteq(end_time) &
      user_id.eq(id)
    }
  end

  def accept!
    update!(value: pending_value, pending_value: nil)
    owner.followers.find_or_create_by(user: user) if owner.respond_to?(:followers)
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
