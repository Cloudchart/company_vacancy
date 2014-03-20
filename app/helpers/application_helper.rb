module ApplicationHelper
  
  def font_awesome(class_names)
    class_names = class_names.split(' ').map { |class_name| "fa-#{class_name}"}.join(' ')
    content_tag(:i, nil, class: "fa #{class_names}")
  end
  
  def first_error(model, name)
    model.errors.full_messages_for(name).first
  end
  
end
