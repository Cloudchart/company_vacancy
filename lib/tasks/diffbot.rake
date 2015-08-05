namespace :cc do

  desc 'Crawl pins origins with diffbot'
  task crawl_pins_origins: :environment do
    Pin.where.not(origin: nil).each do |pin|
      if pin.origin_uri
        DiffbotWorker.perform_async(pin.id, Pin.name, :origin, pin.origin)
        puts "started to process #{pin.origin}"
      end
    end
  end

end
