class CompanyDecorator < ApplicationDecorator
  decorates :company

  def about
    strip_tags(company.blocks.find_by(section: 'about').try(:paragraphs).try(:first).try(:content))
  end

end
