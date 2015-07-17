class TwitterHandleValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /^[A-Za-z0-9_]{1,15}$/
      record.errors[attribute] << (options[:message] || I18n.t('messages.validations.invalid_twitter_hanlde'))
    end
  end
end
