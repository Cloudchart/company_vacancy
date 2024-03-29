class Subscription < ActiveRecord::Base  
  include Uuidable
  
  TYPES = %i[company_page vacancies events]

  belongs_to :user
  belongs_to :subscribable, polymorphic: true

  scope :with_type, -> type { where("types_mask & #{2**TYPES.index(type)} > 0") }

  def types=(types)
    types = types.is_a?(Hash) ? types.values : types
    types = types.map(&:to_sym)
    self.types_mask = (types & TYPES).map { |r| 2**TYPES.index(r) }.sum
  end
  
  def types
    TYPES.reject { |r| ((types_mask || 0) & 2**TYPES.index(r)).zero? }
  end

end
