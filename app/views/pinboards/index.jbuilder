pins = current_user.pins.where(pinboard_id: @pinboards.map(&:uuid)).order(:created_at).select(:uuid, :user_id, :pinboard_id, :created_at)

json.pins pins do |pin|
  json.(pin, :uuid, :user_id, :pinboard_id, :created_at)
  json.set! '--part--', true
end

json.pinboards @pinboards do |pinboard|
  json.partial! 'pinboard', pinboard: pinboard
end
