module Sectionable
  extend ActiveSupport::Concern

  included do
    before_destroy :mark_for_destruction
    serialize :sections, OpenStruct
    has_many :blocks, -> { order(:section, :position) }, as: :owner, dependent: :destroy, inverse_of: :owner
  end

  def blocks_by_section(section)
    section = section.to_s
    blocks.select { |b| b.section == section }
  end  

end
