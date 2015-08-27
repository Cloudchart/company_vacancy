namespace :cc do

  [:pin, :company, :user, :pinboard].each do |name|

    task :"generate_#{name}_preview" => :environment do
      klass_name  = name.to_s.classify
      klass       = klass_name.constantize
      klass.transaction do
        klass.find_in_batches do |items|
          items.each do |item|
            PreviewWorker.perform_async(klass_name, item.id)
          end
        end
      end
    end

  end

end
