namespace :cc do

  task calculate_insight_weight: :environment do
    Pin.transaction do
      Company.includes(:users).find_in_batches do |companies|
        companies.each do |company|
          company.posts.find_in_batches do |posts|
            posts.each do |post|
              post.pins.includes(:children, user: [:people, :unicorn_role]).where.not(content: nil).find_in_batches do |insights|
                insights.each do |insight|

                  weight = insight.children.size

                  if insight.user.unicorn_role.present?
                    weight = weight * 10
                  elsif company.users.include?(insight.user)
                    weight = weight * 5
                  end

                  insight.update(weight: weight)

                end
              end
            end
          end
        end
      end
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
