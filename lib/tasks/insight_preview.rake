namespace :cc do

  task generate_insight_preview: :environment do
    Pin.transaction do
      Pin.insights.find_in_batches do |insights|
        insights.each do |insight|
          PreviewWorker.perform_async('Pin', insight.id)
        end
      end
    end
  end

end
