class SubscriptionsWorker < ApplicationWorker

  def perform(user_id, action, trackable_id, trackable_type, source_id, source_type, group_type)
    user = User.find(user_id)
    trackable = trackable_type.constantize.find(trackable_id)

    source = if source_id && source_type
      source_type.constantize.find(source_id)
    else
      nil
    end

    trackable.company.subscriptions.map(&:user_id).each do |subscriber_id|
      if group_type
        Activity.where(subscriber_id: subscriber_id, trackable_id: trackable.id).order(created_at: :desc).first.update(group_type: group_type)
      else
        Activity.create(user: user, action: action, trackable: trackable, source: source, subscriber_id: subscriber_id)
      end
    end
    
  end

end
