class CompanyPresenter < BasePresenter
  presents :company
  delegate :description, to: :company

  def empty_or_filled_section(section)
    company.blocks.where(section: section).any? ? '' : 'empty'
  end

  def logo
    image_tag company.logo.url
  end

  def text_hint(section)
    first_block = company.blocks.find_by(section: section, blockable_type: 'Text', position: 0)

    if first_block
      content_tag(:p, first_block.blockable.content)
    else
      content_tag(:p, t("blocks.hints.#{section}.text"), class: 'empty')
    end
  end

  def chart_hint
    content_tag(:div, nil, class: 'chart-template') do
      content_tag(:div, t('blocks.hints.default.chart'), class: 'chart-hint')
    end
  end

  def shifted_blocks(section)
    company.blocks.where('section = ? and position > ?', section, 0)
  end

end
