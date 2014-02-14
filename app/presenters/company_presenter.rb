# TODO: destroy unused methods
class CompanyPresenter < Presenter::Base
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
      blockable_content(first_block)
    else
      content_tag(:p, t(".text"), class: 'empty')
    end
  end

  def chart_hint
    content_tag(:div, class: 'chart-template') do
      content_tag(:div, class: 'chart-hint') do
        content_tag(:i, nil, class: 'fa fa-table bold') +
        content_tag(:span, t('.chart'), class: 'bold')
      end
    end
  end

  def image_hint
    content_tag(:div, class: 'image-template') do
      content_tag(:div, class: 'image-hint') do
        content_tag(:i, nil, class: 'fa fa-picture-o') +
        content_tag(:h4, t(".image_title")) +
        content_tag(:p, t(".image_text"))
      end
    end
  end

  def person_hint(person)
    content_tag(:div, class: 'person-template') do
      content_tag(:div, class: 'person-hint') do
        content_tag(:i, nil, class: 'fa fa-user') +
        content_tag(:span, t(".#{person}"), class: 'bold')        
      end
    end
  end

  def shifted_blocks(section)
    company.blocks.where('section = ? and position > ?', section, 0)
  end

  def blockable_content(block)
    '<p>'.tap do |content|
      content << content_tag(:i, nil, class: 'fa fa-bars') unless block.position == 0
      content << block_content(block)
      content << block_actions(block)
      content << '</p>'
    end.html_safe
  end

  private

    def block_content(block)
      case block.blockable_type
      when 'Text' then block.blockable.content
      when 'Image' then image_tag block.blockable.image.thumb.url
      end
    end

    # temporary
    def block_actions(block)
      '<br>'.tap do |content|
          content << link_to("#{t('lexicon.destroy')}", block.blockable, method: :delete, data: { confirm: t('messages.are_you_sure') })
          content << ' '
          content << link_to('↑', blocks_update_position_path(block_id: block.id, shift: :up ), method: :post) unless block.position == 1 || block.position == 0
          content << ' '
          content << link_to('↓', blocks_update_position_path(block_id: block.id, shift: :down ), method: :post) unless last_block?(block) || block.position == 0
      end
    end

    # temporary
    def last_block?(block)
      block == Block.where(section: block.section).order(:position).last
    end

end
