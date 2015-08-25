class AlgoliaSearchWorker < ApplicationWorker

  def perform(id, class_name, remove)
    klass = class_name.constantize
    klass = klass.with_deleted if klass.respond_to?(:with_deleted)
    object = klass.find(id)
    remove ? object.remove_from_index! : object.index!
  end

end
