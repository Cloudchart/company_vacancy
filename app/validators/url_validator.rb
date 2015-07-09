class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || I18n.t('messages.validations.invalid_url')) unless url_valid?(value)
  end

  def url_valid?(url)
    url = url.to_s
    uri = URI.parse(url) rescue false
    uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
  end
end
