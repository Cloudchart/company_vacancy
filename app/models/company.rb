class Company < ActiveRecord::Base
  include Uuidable

  SECTIONS = %i(about product people vacancies contacts).inject({}) { |hash, val| hash.merge({ I18n.t("company.sections.#{val}") => val }) }

  mount_uploader :logo, LogoUploader

  before_destroy :destroy_blocks

  has_many :blocks, -> { includes(blockable: :block).order(:section, :position) }, as: :owner
  has_many :vacancies, dependent: :destroy

  validates :name, presence: true

  private

    # custom dependent destroy because of polymorphic association in block model
    def destroy_blocks
      blocks.each { |block| block.blockable.destroy }
    end
    
end
