<% %w(paragraph block_image).each do |block_type| %>

  <% if params[:block][:"#{block_type.pluralize}_attributes"].present? %>
    $('#<%= params[:id] %>')
      .html('<%= j render "shared/editable_blocks/#{block_type}", block: Block.find(params[:id]) %>');  
  <% end %>

<% end %>
