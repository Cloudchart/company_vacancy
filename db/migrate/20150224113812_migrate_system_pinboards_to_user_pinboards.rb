class MigrateSystemPinboardsToUserPinboards < ActiveRecord::Migration
  def up
    say 'Starting to migrate system pinboards to user pinboards...'
    Pin.joins(:user, :pinboard).where(pinboard_id: Pinboard.system.map(&:id)).each do |pin|
      pin.update!(pinboard: Pinboard.find_or_create_by!(user: pin.user, title: pin.pinboard.title, access_rights: 'public'))
      say "Pinboard #{pin.pinboard.title} found or created for user #{pin.user.full_name}", true
    end
  end

  def down
    say 'Nothing to be done'
  end
end
