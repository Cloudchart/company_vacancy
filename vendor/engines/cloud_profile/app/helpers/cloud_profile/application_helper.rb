module CloudProfile
  module ApplicationHelper
    

    def cloud_profile_nav_current_tab(tab = nil)
      @cloud_profile_nav_current_tab = tab if tab.present?
      @cloud_profile_nav_current_tab
    end
    

    def cloud_profile_nav(&block)
      content_tag :ul do
        yield if block_given?
      end
    end
    

    def cloud_profile_nav_tab(anchor, name, url)
      content_tag(:li, link_to(name, url, class: anchor == cloud_profile_nav_current_tab ? :current : nil))
    end
    

  end
end
