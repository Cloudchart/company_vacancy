module Sectionable
  extend ActiveSupport::Concern

  included do
    after_validation :set_sections
    before_destroy :mark_for_destruction
    serialize :sections, OpenStruct
    has_many :blocks, -> { order(:section, :position) }, as: :owner, dependent: :destroy, inverse_of: :owner
  end

  def blocks_by_section(section)
    section = section.to_s
    blocks.select { |b| b.section == section }
  end

  def should_build_objects?
    !!@should_build_objects
  end

  def should_build_objects!
    @should_build_objects = true
  end
  
private

  def set_sections
    self.class::SECTIONS.values.each { |section| sections.send("#{section}=", nil) }
  end

end
