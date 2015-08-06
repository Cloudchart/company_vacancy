namespace :cc do

  desc 'Crawl pins origins with diffbot'
  task crawl_pins_origins: :environment do
    DiffbotResponseOwner.delete_all
    Pin.insights.where.not(origin: nil).each do |pin|
      if pin.origin_uri
        DiffbotWorker.perform_async(pin.id, pin.class.name, :origin)
        puts "started to process #{pin.origin}"
      end
    end
  end

end
