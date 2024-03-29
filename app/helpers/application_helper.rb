module ApplicationHelper

  def set_meta_tags_for_social_networks(scope = {})
    set_meta_tags(
      og: {
        title: scope[:title],
        description: scope[:description],
        image: scope[:image],
        url: scope[:url]
      },
      twitter: {
        title: scope[:title],
        description: scope[:description],
        image: scope[:image],
        card: 'summary_large_image',
        site: "@#{ENV['TWITTER_APP_NAME']}"
      }
    )
  end

  def decorate(object, klass=nil)
    klass ||= "#{object.class}Decorator".constantize
    decorator = klass.new(object)
    yield decorator if block_given?
    decorator
  end

  def link_with_class_for_current(name, path, class_name='')
    link_to name, path, class: "#{class_name}#{current_page?(path) ? ' current' : ''}"
  end

  def class_for_main(content = nil)
    if content
      @view_flow.set(:class_for_main, content.to_s)
    else
      @view_flow.get(:class_for_main).presence
    end
  end

  def class_for_root_tag(options = {})
    options.each do |name, value|
      @view_flow.set(:"class_for_#{name}", value.to_s)
    end
  end

  def font_awesome(class_names, content = nil)
    class_names = class_names.split(' ').map { |class_name| "fa-#{class_name}"}.join(' ')
    content_tag(:i, content, class: "fa #{class_names}")
  end

  def has_errors(model, name)
    model.errors.full_messages_for(name).size > 0
  end

  def first_error(model, name)
    model.errors.full_messages_for(name).first
  end

  def ams(collection, options = {})
    collection.active_model_serializer.new(collection, options)
  end

  def app_logo_for_header(options={})
    image_tag "#{Rails.env}/insights-neg.svg"
  end

  def app_name_for_header
    if Rails.env.staging?
      raw "Soviet <strong>Union</strong>"
    else
      raw "Insights.<strong>VC</strong>"
    end
  end

end
