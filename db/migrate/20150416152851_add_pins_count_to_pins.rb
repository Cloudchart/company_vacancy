class AddPinsCountToPins < ActiveRecord::Migration
  def up
    add_column :pins, :pins_count, :integer, default: 0
    Pin.all.each { |pin| Pin.reset_counters(pin.id, :children) }
  end

  def down
    remove_column :pins, :pins_count
  end
end
