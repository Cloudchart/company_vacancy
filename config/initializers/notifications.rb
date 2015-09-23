# ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
# end

# {
#   :controller=>"PinboardsController",
#   :action=>"show",
#   :params=>{"controller"=>"pinboards", "action"=>"show", "id"=>"bf408d69-b0b8-45a0-a6af-967a969a5feb"},
#   :format=>:html,
#   :method=>"GET",
#   :path=>"/collections/bf408d69-b0b8-45a0-a6af-967a969a5feb",
#   :status=>200,
#   :view_runtime=>1369.181,
#   :db_runtime=>21.762999999999998
# }

ActiveSupport::Notifications.subscribe 'pinboards#create' do |name, start, finish, id, payload|
  if Cloudchart::SHOULD_PERFORM_SIDEKIQ_WORKER && payload[:id].present?
    NotificationsBreakdownWorker.perform_async(payload[:id], 'Pinboard')
  end
end

ActiveSupport::Notifications.subscribe 'pins#create' do |name, start, finish, id, payload|
  if Cloudchart::SHOULD_PERFORM_SIDEKIQ_WORKER && payload[:id].present?
    NotificationsBreakdownWorker.perform_async(payload[:id], 'Pin')
  end
end
