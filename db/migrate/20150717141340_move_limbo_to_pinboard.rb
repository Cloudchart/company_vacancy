class MoveLimboToPinboard < ActiveRecord::Migration
  def up
    say 'Starting to move limbo pins...'

    pinboard = Pinboard.find_or_create_by!(
      title: 'Limbo', 
      position: 222,
      access_rights: 'private',
      suggestion_rights: 'editors'
    )

    say 'created limbo pinboard', true

    Pin.where.not(author_id: nil).each do |pin|
      if pin.is_suggestion?
        pin.update(user_id: pin.author_id)
        say 'updated user for suggestion', true
      else
        pin.update(pinboard_id: pinboard.id)
        say 'updated pinboard for limbo pin', true
      end
    end

    remove_index :pins, :author_id
    remove_column :pins, :author_id
  end

  def down
    add_column :pins, :author_id, :string, limit: 36
    add_index :pins, :author_id
  end
end
