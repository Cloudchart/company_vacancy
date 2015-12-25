namespace :cc do

  desc 'Crawl pins origins with diffbot'
  task :crawl_pins_origins, [:force] => [:environment] do |t, options|
    if options[:force]
      DiffbotResponse.destroy_all
      puts 'forcibly destroyed all diffbot responses'
    else
      DiffbotResponseOwner.delete_all
    end

    Pin.insights.where.not(origin: nil).each do |pin|
      if pin.origin_uri
        DiffbotWorker.perform_async(pin.id, pin.class.name, :origin)
        puts "started to process #{pin.origin}"
      end
    end
  end

  desc 'Get tags from diffbot responses'
  task get_tags_from_diffbot_responses: :environment do
    DiffbotResponse.includes(pins: :tags).where(api: :article).each do |response|
      next unless tags = response.body[:objects].first[:tags]

      tags.map { |tag| tag[:label].parameterize }.each do |tag_name|
        next unless tag_name.present?

        response.pins.each do |pin|
          tag = Tag.find_or_create_by(name: tag_name)
          pin.tags << tag unless pin.tags.include?(tag)
          puts "processed #{tag_name}"
        end
      end
    end
  end

end
