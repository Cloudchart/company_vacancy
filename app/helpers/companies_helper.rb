module CompaniesHelper
  def blockable_content(block)
    case block.blockable_type
    when 'Text' then block.blockable.content
    when 'Image' then image_tag block.blockable.image.thumb.url
    end
  end
end
