module Sectionable
  extend ActiveSupport::Concern

  included do
    serialize         :sections, OpenStruct

    after_validation  :build_objects, if: :should_build_objects?
    before_destroy    :mark_for_destruction
    before_create     :initialize_sections

    has_many :blocks, -> { order(:section, :position) }, as: :owner, dependent: :destroy, inverse_of: :owner
  end


  def blocks_by_section(section)
    section = section.to_s
    blocks.select { |b| b.section == section }
  end


  def should_build_objects!
    @should_build_objects = true
  end


  def should_build_objects?
    !!@should_build_objects
  end
  
  
  def sections_attributes=(attributes = {})
    attributes.each { |key, value| sections[key] = value }
  end


private

  def initialize_sections
    self.sections = OpenStruct.new
  end
  
end
