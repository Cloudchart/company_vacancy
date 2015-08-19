class MoveLimboToPinboard < ActiveRecord::Migration
  def up
    say 'Starting to move limbo pins...'

    pinboard = Pinboard.find_or_initialize_by(title: 'Limbo', position: 222)

    if pinboard.new_record?
      pinboard.access_rights = 'private'
      pinboard.suggestion_rights = 'editors'
      pinboard.save!
      say 'created limbo pinboard', true
    end

    Pin.where.not(author_id: nil).where('created_at < ?', '2015-07-16 11:00:00 UTC').each do |pin|
      if pin.is_suggestion?
        pin.update!(user_id: pin.author_id)
        say 'updated user for suggestion', true
      else
        Pin.create!(
          user_id: pin.author_id,
          parent: pin,
          pinboard: pinboard,
          pinnable: pin.pinnable
        )
        say 'repined insight to limbo', true
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
