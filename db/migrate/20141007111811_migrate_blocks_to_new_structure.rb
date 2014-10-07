class MigrateBlocksToNewStructure < ActiveRecord::Migration
  def up
    say 'Starting to migrate blocks'
    Block.where(owner_type: 'Company').each do |block|
      case block.identity_type
      when 'BlockImage'
        if block.block_images.first
          block.build_picture(image: File.open(File.join(Rails.root, 'public', block.block_images.first.image.url)))
          block.identity_type = 'Picture'
          block.save
          say "Updated BlockImage", true
        else
          block.destroy
          say "Destroyed BlockImage", true
        end
      when 'Paragraph'
        if block.paragraphs.first
          block.paragraphs.first.update(owner: block)
          say "Updated Paragraph", true
        else
          block.destroy
          say "Destroyed Paragraph", true
        end
      end
    end

    say 'Starting to reposition blocks'
    Company.all.each do |company|
      Block.where(owner: company).order(:section, :position).each_with_index do |block, index|
        block.update(position: index)
        say 'Updated block position', true
      end
    end
  end

  def down
    # this can not be undone
  end
end
