namespace :cc do

  task generate_insight_preview: :environment do
    Pin.transaction do
      Pin.find_in_batches do |pins|
        pins.each do |pin|
          PreviewWorker.perform_async('Pin', pin.id)
        end
      end
    end
  end

end
