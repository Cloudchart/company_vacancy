class UserShape < CloudShape


  scope :emails do |sources, shape|
    emails          = CloudProfile::Email.where(user_id: sources.map(&:uuid)).to_a
    shaped_emails   = shape(emails, shape)

    sources.reduce({}) do |memo, source|
      ids = emails.select { |item| item.user_id == source.uuid }
      memo[source.uuid] = shaped_emails.select { |item| ids.include?(item[:id]) }
      memo
    end
  end


  scope :pinboards do |sources, shape|
    pinboards           = Pinboard.where(user_id: sources.map(&:uuid)).to_a
    shaped_pinboards    = shape(pinboards, shape)

    sources.reduce({}) do |memo, source|
      ids = pinboards.select { |item| item.user_id == source.uuid }.map(&:uuid)
      memo[source.uuid] = shaped_pinboards.select { |item| ids.include?(item[:id]) }
      memo
    end
  end


  scope :readable_pinboards do |sources, shape|
    grouped_pinboards = select_readable_pinboards(sources.map(&:uuid))
    shaped_pinboards  = shape(grouped_pinboards.values.flatten.compact.uniq, shape)

    sources.reduce({}) do |memo, source|
      ids = grouped_pinboards[source.uuid].map(&:uuid)
      memo[source.uuid] = shaped_pinboards.select { |item| ids.include?(item[:id]) }
      memo
    end
  end


  def avatar_url
    avatar.url if avatar_stored?
  end


private

  def self.select_readable_pinboards(user_ids)
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

    pinboards = roles.map(&:pinboard).flatten

    user_ids.reduce({}) do |memo, user_id|
      ids = roles.select { |role| role.user_id == user_id }.map(&:owner_id)
      memo[user_id] = pinboards.select { |item| ids.include? item.uuid }
      memo
    end
  end


end
