class AddKindToPin < ActiveRecord::Migration
  def up
    add_column :pins, :kind, :string
    add_index :pins, :kind

    Pin.transaction do
      Pin.where(parent_id: nil).where.not(content: nil).each do |pin|
        pin.kind = 'insight'
        pin.save
      end

      Pin.where(is_suggestion: true).each do |pin|
        pin.kind = 'suggestion'
        pin.save
      end
    end
  end

  def down
    remove_index :pins, :kind
    remove_column :pins, :kind
  end
end
