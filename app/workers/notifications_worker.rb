class NotificationsWorker < ApplicationWorker
  include Sidetiq::Schedulable

  recurrence { minutely(15) }

  def perform(last_occurrence, current_occurrence)
    puts last_occurrence, current_occurrence
  end

end
