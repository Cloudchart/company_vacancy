class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless (Date.parse(value.to_s) rescue false)
      record.errors[attribute] << (options[:message] || I18n.t('messages.validations.invalid_date'))
    end
  end
end
