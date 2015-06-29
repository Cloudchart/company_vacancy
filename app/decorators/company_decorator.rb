class CompanyDecorator < ApplicationDecorator
  decorates :company

  def name
    company.name.present? ? company.name : 'Unnamed'
  end

  def tags
    company.tags.map { |tag| "##{tag.name}" }.join(', ')
  end

end
