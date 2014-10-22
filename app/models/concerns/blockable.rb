module Blockable
  extend ActiveSupport::Concern

  included do
    after_validation  :build_objects, if: :should_build_objects?
    before_destroy    :mark_for_destruction

    has_many :blocks, -> { order(:position) }, as: :owner, dependent: :destroy, inverse_of: :owner
  end

  def should_build_objects!
    @should_build_objects = true
  end

  def should_build_objects?
    !!@should_build_objects
  end
  
end
