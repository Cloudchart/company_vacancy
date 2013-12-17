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
end
