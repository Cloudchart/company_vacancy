class BaseShape

  include Rails.application.routes.mounted_helpers
  include Rails.application.routes.url_helpers

  class << self

    def shape(records, fields, scope)
      wrapped_records = wrap_records(records)

      preload(wrapped_records, fields, scope)

      root = { root: {}, data: {} }

      rendered_records = wrapped_records.map { |record| record.render(root[:data], fields) }

      root[:root] = records.respond_to?(:first) && !records.is_a?(Hash) ? rendered_records : rendered_records.first

      root
    end

  private

    def wrap_records(records)
      Array.wrap(records).compact.map { |record| wrap_record(record) }
    end

    def wrap_record(record)
      shape_class = "#{record.class.name}RelayShape".safe_constantize || self
      shape_class.new(record)
    end

    def filter_records(records, scope)
      Array.wrap(records).select do |record|
        if scope[:persmissions][:can][:read].include?(record.class.name)
          scope[:ability].can?(:read, record)
        else
          true
        end
      end
    end

    def preload(records, fields, scope)
      grouped_records = {}

      records.each { |record| (grouped_records[record.source.class] ||= []) << record }

      return unless fields

      fields.each do |field, child_fields|
        wrapped_children = []

        grouped_records.each do |group_class, group_records|

          if group_class.respond_to?(:reflect_on_association) && group_class.reflect_on_association(field)
            Preloadable::preload(group_records.map(&:source), [], field)
          elsif group_class.respond_to?("preload_#{field}")
            group_class.public_send(:"preload_#{field}", group_records.map(&:source), [])
          end

          group_records.each do |group_record|
            values          = group_record.public_send(field) rescue group_record[field.to_sym]
            filtered_values = filter_records(values, scope)

            wrapped_values  = wrap_records(filtered_values)
            wrapped_value   = values.respond_to?(:first) && !values.is_a?(Hash) ? wrapped_values : wrapped_values.first

            group_record.define_singleton_method(field) { wrapped_value }

            wrapped_children.concat(wrapped_values)
          end

        end

        preload(wrapped_children, child_fields, scope)
      end
    end

  end


  attr_reader :source

  def initialize(source)
    @source = source
  end

  def render(root, fields = {})
    edge      = nil
    context   = {}

    if source.respond_to?(:id)
      root[source.class.name] ||= {}
      context = root[source.class.name][source.id] ||= {}
      edge    = {
        "$ref": {
          id:   source.id,
          type: source.class.name
        }
      }
    end

    result = if fields.blank? || fields.empty?
      source.as_json
    else
      fields.each do |field, child_fields|
        values            = public_send(field)
        wrapped_values    = Array.wrap(values).map { |v| v.render(root, child_fields) }
        context[field]    = values.respond_to?(:first) && !values.is_a?(Hash) ? wrapped_values : wrapped_values.first
      end
      context
    end

    edge || result
  end


  def method_missing(name, *args, &block)
    if source.respond_to?(name)
      source.send(name, *args, &block)
    else
      super
    end
  end

end
