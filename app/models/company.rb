class Company < ActiveRecord::Base
  include Uuidable

  SECTIONS = %i(about product people vacancies contacts).inject({}) { |hash, val| hash.merge({ I18n.t("company.sections.#{val}") => val }) }

  before_destroy :destroy_blocks

  belongs_to :logo, dependent: :destroy
  has_many :blocks, -> { includes(block_identities: :identity).order(:section, :position) }, as: :owner, dependent: :destroy
  has_many :vacancies, dependent: :destroy

  accepts_nested_attributes_for :logo

  validates :name, presence: true
  
  def blocks_by_section(section)
    section = section.to_s
    blocks.select { |b| b.section == section }
  end  

  private
    # custom dependent destroy because of polymorphic association in block model
    def destroy_blocks
      blocks.each { |block| block.blockable.destroy }
    end
    
end
