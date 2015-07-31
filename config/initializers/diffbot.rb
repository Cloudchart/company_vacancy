 DIFFBOT_CLIENT = Diffbot::APIClient.new do |config|
  config.token = ENV['DIFFBOT_TOKEN']
end

DIFFBOT_ARTICLE = DIFFBOT_CLIENT.article(version: 3)
DIFFBOT_ANALYZE = DIFFBOT_CLIENT.analyze(version: 3)
