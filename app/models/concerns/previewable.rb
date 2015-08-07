module Previewable
  extend ActiveSupport::Concern


  included do
    dragonfly_accessor :preview
    after_save :generate_preview
  end


  def should_skip_generate_preview?
    !!@should_skip_generate_preview
  end

  def skip_generate_preview!
    @should_skip_generate_preview = true
  end

  def generate_preview
    return if try(:deleted?)
    PreviewWorker.perform_async(self.class.name, id) unless should_skip_generate_preview?
  end


end
