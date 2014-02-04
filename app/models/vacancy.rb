class Vacancy < ActiveRecord::Base
  include Uuidable

  serialize :settings, VacancySetting

  SECTIONS = %i(settings vacancy requirements benefits).inject({}) { |hash, val| hash.merge({ I18n.t("vacancy.sections.#{val}") => val }) }

  belongs_to :company

  validates :name, presence: true

  def settings=(hash)
    # temporary date params conversion
    # must use rails helper here
    # http://apidock.com/rails/v4.0.2/ActiveRecord/AttributeAssignment/assign_multiparameter_attributes
    if !!hash.keys.detect { |k| k.to_s =~ /publish_on/ }
      date_string = "#{hash['publish_on(1i)']}-#{hash['publish_on(2i)']}-#{hash['publish_on(3i)']}"
      hash.delete_if { |k,v| k =~ /publish_on/ }
      hash[:publish_on] = date_string
    end

    hash.each do |key, value|
      self.settings.send("#{key}=", value)
    end
  end

end
