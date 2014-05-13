class ApplicationWorker
  include Sidekiq::Worker
  # https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/worker.rb
  # sidekiq_options retry: false  
end
