class AppUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless url_valid?(value)
      record.errors[attribute] << (options[:message] || I18n.t('messages.validations.invalid_app_url', host: ENV['APP_HOST']))
    end
  end

  def url_valid?(url)
    url = url.to_s
    return false unless url.match(ENV['APP_HOST'])
    uri = URI.parse(url) rescue false
    uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
  end
end
