class Vacancy < ActiveRecord::Base
  include Uuidable
  include Blockable
  include Trackable

  before_create :set_default_status
  
  is_impressionable counter_cache: true, unique: true

  serialize :settings, VacancySetting
  
  belongs_to :company
  belongs_to :author, class_name: 'User'

  has_one :block_identity, as: :identity, inverse_of: :identity
  has_many :node_identities, as: :identity, dependent: :destroy, class_name: CloudBlueprint::Identity
  has_many :responses, class_name: 'VacancyResponse'
  has_many :responded_users, through: :responses, source: :user
  has_and_belongs_to_many :reviewers, class_name: 'Person', join_table: 'vacancy_reviewers'
  # has_paper_trail

  validates :name, presence: true
  validate :validity_of_settings

  scope :later_then, -> (date) { where arel_table[:updated_at].gteq(date) }
  scope :by_status, -> (status) { where status: status }

  def settings=(hash)
    settings.attributes = hash
  end

  def as_json_for_chart
    as_json(only: [:uuid, :name, :description])
  end

private

  def validity_of_settings
    errors.add(:settings, settings.errors) unless settings.valid?
  end

  def build_objects
    # blocks.build(position: 0, identity_type: 'Paragraph', is_locked: true)
  end

  # TODO: return :draft
  def set_default_status
    self.status = :opened
  end

end
