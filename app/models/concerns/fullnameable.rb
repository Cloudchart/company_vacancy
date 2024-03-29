module Fullnameable
  extend ActiveSupport::Concern

  def full_name
    @full_name ||= [first_name, last_name].reject(&:blank?).join(' ')
  end
  
  def full_name=(full_name)
    full_name = full_name.to_s
    parts = full_name.split(/\s+/).select { |part| part.present? }
    self.first_name = parts.first
    self.last_name = parts.any? ? parts.drop(1).join(' ') : nil
  end

end
