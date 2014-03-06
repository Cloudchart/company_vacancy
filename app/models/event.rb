class Event < ActiveRecord::Base
  include Uuidable
  include Sectionable

  SECTIONS = %i(about participants).inject({}) { |hash, val| hash.merge({ I18n.t("event.sections.#{val}") => val }) }
  BLOCK_TYPES = %i(paragraph block_image company).inject({}) { |hash, val| hash.merge({ I18n.t("block.types.#{val}") => val }) }  

  before_create :build_sections_and_locked_blocks

  validates :name, presence: true

private

  def build_sections_and_locked_blocks
    SECTIONS.values.each { |section| sections.send("#{section}=", nil) }
    blocks.build(section: :about, position: 0, identity_type: 'Paragraph', is_locked: true)
    blocks.build(section: :about, position: 1, identity_type: 'BlockImage', is_locked: true)
    blocks.build(section: :participants, position: 0, identity_type: 'Company', is_locked: true)
  end

end
