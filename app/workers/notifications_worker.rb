class NotificationsWorker < ApplicationWorker

  sidekiq_options queue: :notification

  def perform()
    
  end

end
