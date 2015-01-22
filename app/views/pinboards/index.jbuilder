pins = current_user.pins.where(pinboard_id: @pinboards.map(&:uuid)).order(:created_at).select(:uuid, :pinboard_id, :created_at)

json.pins pins do |pin|
  json.(pin, :uuid, :pinboard_id, :created_at)
  json.transparent true
end

json.pinboards @pinboards do |pinboard|
  json.partial! 'pinboard', pinboard: pinboard
end
