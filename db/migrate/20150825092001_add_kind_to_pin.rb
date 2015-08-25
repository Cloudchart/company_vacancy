class AddKindToPin < ActiveRecord::Migration
  def up
    add_column :pins, :kind, :string
    add_index :pins, :kind

    Pin.transaction do
      Pin.without_auto_index do
        Pin.where(parent_id: nil).where.not(content: nil).each do |pin|
          pin.kind = 'insight'
          pin.skip_generate_preview!
          pin.save
        end

        Pin.where(is_suggestion: true).each do |pin|
          pin.kind = 'suggestion'
          pin.skip_generate_preview!
          pin.save
        end
      end
    end
  end

  def down
    remove_index :pins, :kind
    remove_column :pins, :kind
  end
end
