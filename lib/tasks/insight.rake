namespace :cc do

  desc 'Rebuilds weight for all insights'
  task rebuild_insights_weight: :environment do
    Pin.insights.includes(:children, followers: { user: :roles }).find_each do |insight|
      insight.rebuild_weight!
      puts "#{insight.id} – updated weight: #{insight.weight}"
    end
  end

  desc 'Updates blank insight origin with post url'
  task update_blank_insight_origin_with_post_url: :environment do
    Pin.insights.where(origin: nil, pinnable_type: 'Post').each do |pin|
      pin.update(origin: Rails.application.routes.url_helpers.post_url(pin.pinnable))
      DiffbotWorker.perform_async(pin.id, pin.class.name, :origin)
      puts "insight #{pin.id} updated"
    end
  end

end
