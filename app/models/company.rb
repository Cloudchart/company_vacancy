class Company < ActiveRecord::Base
  include Uuidable

  mount_uploader :logo, LogoUploader

  before_destroy :destroy_blocks

  has_many :blocks, -> { includes(blockable: :block).order(:kind, :position) }, as: :owner

  validates :name, presence: true

  private

    # custom dependent destroy because of polymorphic association in block model
    def destroy_blocks
      blocks.each { |block| block.blockable.destroy }
    end
    
end
