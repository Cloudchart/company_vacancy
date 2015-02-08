class SeparateQuotesFromParagraphs < ActiveRecord::Migration
  def up
    say "Starting to separate quotes"
    Block.where(owner_type: "Post", kind: "Quote").each do |block|
      ActiveRecord::Base.transaction do
        paragraph = block.paragraph
        block.update(identity_type: "Quote", kind: nil)
        say "Updated Block", true

        if paragraph.present?
          text = paragraph.content
          paragraph.destroy 
          say "Destroyed Paragraph", true
        else
          text = ""
        end

        quote = block.build_quote(text: text)
        quote.save
        say "Created Quote", true
      end
    end
  end

  def down
    say "starting to rollback quotes"
    Block.where(owner_type: "Post", identity_type: "Quote").each do |block|
      ActiveRecord::Base.transaction do
        quote = block.quote
        block.update(identity_type: "Paragraph", kind: "Quote")
        say "Updated Block", true

        if quote.present?
          text = quote.text

          if text.present?
            paragraph = block.build_paragraph(content: text)
            paragraph.save
            say "Created Paragraph", true
          end

          quote.destroy
          say "Destroyed Quote", true
        end
      end
    end
  end
end
