class SeparateQuotesFromParagraphs < ActiveRecord::Migration
  def up
    say "Starting to separate quotes"
    Block.where(owner_type: "Post", kind: "Quote").each do |block|
      ActiveRecord::Base.transaction do
        paragraph = block.paragraph
        block.update(identity_type: "Quote", kind: nil)
        say "Updated Block", true

        owner = block.owner
        blocks = owner.blocks
        block_index = blocks.find_index(block)
        next_block = blocks[block_index + 1]

        if next_block.present? && next_block.identity_type == "Person"
          person_id = next_block.block_identities.first.identity_id
          next_block.destroy
          say "Destroyed Person", true
        else
          person_id = nil
        end

        if paragraph.present?
          text = paragraph.content
          paragraph.destroy 
          say "Destroyed Paragraph", true
        else
          text = ""
        end

        quote = block.build_quote(text: text, person_id: person_id)
        quote.save
        say "Created Quote", true
      end
    end
  end

  def down
    say "Starting to rollback quotes"
    Block.where(owner_type: "Post", identity_type: "Quote").each do |block|
      ActiveRecord::Base.transaction do
        quote = block.quote
        block.update(identity_type: "Paragraph", kind: "Quote")
        say "Updated Block", true

        if quote.present?
          text = quote.text
          person_id = quote.person_id

          if text.present?
            paragraph = block.build_paragraph(content: text)
            paragraph.save
            say "Created Paragraph", true
          end

          if person_id.present?
            owner = block.owner
            blocks = owner.blocks

            old_block_ids = blocks.map(&:id)
            quote_block_index = blocks.find_index(block)

            person_block = owner.blocks.build(identity_type: "Person")
            person_block.save!
            person_block.block_identities.create!(identity_id: person_id, identity_type: "Person")

            new_block_ids = old_block_ids.insert(quote_block_index + 1, person_block.id)

            Block.reposition(new_block_ids)
            say "Created Person", true
          end

          quote.destroy
          say "Destroyed Quote", true
        end
      end
    end
  end
end
