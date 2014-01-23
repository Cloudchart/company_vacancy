module BlocksHelper
  def blockable_content(block)
    case block.blockable_type
    when 'Text' then block.blockable.content
    when 'Image' then image_tag block.blockable.image.thumb.url
    end
  end

  def block_actions(block)
    ''.tap do |content|
        content << '<br>'
        content << '| '
        content << link_to("#{t('lexicon.destroy')}", block.blockable, method: :delete, data: { confirm: t('messages.are_you_sure') })
        content << ' | '
        content << link_to('↑', blocks_update_position_path(block_id: block.id, shift: :up ), method: :post) unless block.position == 1
        content << ' | '
        content << link_to('↓', blocks_update_position_path(block_id: block.id, shift: :down ), method: :post) unless last_block?(block)      
    end.html_safe
  end

  private

    # temporary
    def last_block?(block)
      block == Block.where(section: block.section).order(:position).last
    end  

end
