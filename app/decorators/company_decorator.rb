class CompanyDecorator < ApplicationDecorator
  decorates :company

  def name
    company.name.present? ? company.name : 'Unnamed'
  end

  def og_name
    prefix = company.name == ENV['SITE_NAME'] ? '' : "#{ENV['SITE_NAME']}: "
    "#{prefix}#{company.name}"
  end

  def tags
    company.tags.map { |tag| "##{tag.name}" }.join(', ')
  end

end
