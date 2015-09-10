class NotificationsWorker < ApplicationWorker

  sidekiq_options queue: :notifications

  def perform(id, class_name, action_name)
    klass = class_name.constantize

    # initialize objects collection
    objects = []
    objects << klass.find(id)

    # find all scheduled notifications available in 5 min interval
    scheduled_set = Sidekiq::ScheduledSet.new.select do |entry|
      entry['queue'] == 'notifications' &&
      entry['args'].second == class_name &&
      entry['created_at'] <= 5.minutes.from_now.to_i
    end

    # extract and append objects to the collection
    scheduled_set.each do |entry|
      objects << klass.find(entry['args'].first)
    end

    # notify followers
    

    # delete all entries from the schedule set
    scheduled_set.each(&:delete)
  end

end

# {
#          "class" => "NotificationsWorker",
#           "args" => [
#         [0] "create",
#         [1] "Pin",
#         [2] "00243f1e-ee3c-4d8b-b681-3838f974f44d"
#     ],
#          "retry" => true,
#          "queue" => "notifications",
#            "jid" => "45e0d2afafbbd70cc390f5f9",
#     "created_at" => 1441882388.6018949
# }
