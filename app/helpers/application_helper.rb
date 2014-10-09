module ApplicationHelper

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

  def favorites_link(object)
    favorite = current_user.favorites.find_by(favoritable_id: object.id)

    if favorite
      link_to font_awesome('star'), main_app.favorite_path(favorite), method: :delete, remote: true
    else
      link_to font_awesome('star-o'), main_app.favorites_path(favoritable_id: object.id, favoritable_type: object.class.name), method: :post, remote: true
    end
  end
  
end
