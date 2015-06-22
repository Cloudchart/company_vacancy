namespace :cc do

  task :post_to_slack_channel, [:type] => :environment do |t, args|
    SlackWebhooksWorker.perform_async(args[:type], nil, { webhook_url: ENV['SLACK_DEVELOP_WEBHOOK_URL'] })
  end

end
