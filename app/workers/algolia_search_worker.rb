class AlgoliaSearchWorker < ApplicationWorker

  def perform(id, class_name, remove, options={})
    klass = class_name.constantize
    klass = klass.with_deleted if klass.respond_to?(:with_deleted)
    object = klass.find(id)
    options.symbolize_keys!

    if class_name == 'Pinboard' && options[:only_dependencies]
      object.pins.map { |pin| pin.insight? ? pin : pin.parent }.each do |insight|
        insight.index!
      end
    end and return

    remove ? object.remove_from_index! : object.index!
  end

end
