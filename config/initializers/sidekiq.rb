jobs = [
  {
    name: 'Notifications',
    class: 'NotificationsWorker',
    cron: "*/#{Cloudchart::INSTANT_NOTIFICATIONS_TIC} * * * *"
  }
]

Sidekiq::Cron::Job.load_from_array! jobs
