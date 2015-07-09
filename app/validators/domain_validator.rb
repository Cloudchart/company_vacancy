class DomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || I18n.t('messages.validations.invalid_domain')) unless domain_valid?(value)
  end

  def domain_valid?(domain)
    domain = domain.to_s
    domain = "http://#{domain}" unless domain.match(/https?:\/\//)
    uri = URI.parse(domain) rescue false
    uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
  end
end
