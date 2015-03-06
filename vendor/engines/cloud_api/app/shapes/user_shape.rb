class UserShape < CloudShape


  defaults :id, :full_name, :avatar_url

  restricted :password_digest


  scope :readable_pinboards do |sources|
    roles, pinboards = select_readable_pinboards_through_roles(sources.map(&:id))

    sources.each do |source|
      ids = roles.select { |item| item.user_id == source.uuid }.map(&:owner_id)
      source.readable_pinboards = pinboards.select { |item| ids.include?(item.uuid) }
    end
  end


  def avatar_url
    avatar.url if avatar_stored?
  end

private

  def self.select_readable_pinboards_through_roles(user_ids)
    roles = Role
      .joins {
        pinboard
      }
      .where {
        user_id.in(user_ids)
      }
      .where {
        (pinboard.access_rights.eq('public') & value.in(['editor', 'reader', 'follower'])) |
        (pinboard.access_rights.in(['private', 'protected']) & value.in(['editor', 'reader']))
      }
    [roles, roles.map(&:pinboard)]
  end


end
