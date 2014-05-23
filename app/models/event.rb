class Event < ActiveRecord::Base
  include Uuidable
  include Sectionable
  include Trackable

  SECTIONS = %i(about participants).inject({}) { |hash, val| hash.merge({ I18n.t("event.sections.#{val}") => val }) }
  BLOCK_TYPES = %i(paragraph block_image company).inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }

  belongs_to :company
  belongs_to :author, class_name: 'User'
  has_one :token, as: :owner, dependent: :destroy
  # has_paper_trail

  validates :name, presence: true
  validates :url, url: true, allow_blank: true

  def build_objects
    build_token(name: :verification) if url.present?
    blocks.build(section: :about, position: 0, identity_type: 'Paragraph', is_locked: true)
    blocks.build(section: :about, position: 1, identity_type: 'BlockImage', is_locked: true)
    blocks.build(section: :participants, position: 0, identity_type: 'Company', is_locked: true)
  end

end
