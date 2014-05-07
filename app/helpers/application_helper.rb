module ApplicationHelper

  
  def class_for_main(content = nil)
    if content
      @view_flow.set(:class_for_main, content.to_s)
    else
      @view_flow.get(:class_for_main).presence
    end
  end
  
  #
  #
  def class_for_root_tag(options = {})
    options.each do |name, value|
      @view_flow.set(:"class_for_#{name}", value.to_s)
    end
  end
  
  
  # Header Navigation
  #
  

  def cloud_header_nav_current_tab(tab = nil)
    @cloud_header_nav_current_tag = tab if tab.present?
    @cloud_header_nav_current_tag
  end


  def cloud_header_nav
    content_tag :ul, class: :links do
      yield if block_given?
    end
  end
  

  def cloud_header_nav_tab(anchor, name, path)
    content_tag(:li, link_to(name, path, class: anchor.to_sym == cloud_header_nav_current_tab.to_sym ? :current : nil))
  end

  
  #
  #
  
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


  def custom_section?(klass, section)
    if klass == Vacancy && section =~ /settings|vacancy/
      true
    else
      false
    end
  end

end
