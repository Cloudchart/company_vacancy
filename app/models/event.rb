class Event < ActiveRecord::Base
  include Uuidable
  include Sectionable

  SECTIONS = %i(about participants).inject({}) { |hash, val| hash.merge({ I18n.t("event.sections.#{val}") => val }) }
  BLOCK_TYPES = %i(paragraph block_image company).inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }  

  before_create :build_sections_and_locked_blocks
  before_create :build_verification_token, if: 'url.present?'

  has_one :token, as: :owner, dependent: :destroy

  validates :name, presence: true
  validates :url, url: true, allow_blank: true

private

  def build_sections_and_locked_blocks
    SECTIONS.values.each { |section| sections.send("#{section}=", nil) }
    blocks.build(section: :about, position: 0, identity_type: 'Paragraph', is_locked: true)
    blocks.build(section: :about, position: 1, identity_type: 'BlockImage', is_locked: true)
    blocks.build(section: :participants, position: 0, identity_type: 'Company', is_locked: true)
  end

  def build_verification_token
    build_token(name: :verification)
  end

end
