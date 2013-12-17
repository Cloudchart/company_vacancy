module BlocksHelper
    def blockable_content(block)
        case block.blockable_type
        when 'Text' then block.blockable.content
        when 'Image' then image_tag block.blockable.image.thumb.url
        end
    end

    # temporary
    def last_block?(block)
        block == Block.where(kind: block.kind).order(:position).last
    end

    def block_actions(block)
        ''.tap do |content|
            content << link_to("| #{t('destroy')}", block.blockable, method: :delete, data: { confirm: t('confirm') })
            content << link_to('| ↑ |', blocks_update_position_path(block_id: block.id, shift: :up ), method: :post) unless block.position == 0
            content << link_to('| ↓ |', blocks_update_position_path(block_id: block.id, shift: :down ), method: :post) unless last_block?(block)      
        end.html_safe
    end
end
