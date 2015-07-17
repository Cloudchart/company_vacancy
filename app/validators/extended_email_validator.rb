class ExtendedEmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@]+)\s<([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})>\z/i ||
      value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || I18n.t('messages.validations.invalid_email'))
    end
  end
end
