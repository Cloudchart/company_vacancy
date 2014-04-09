<% if params[:block][:block_images_attributes].present? %>
  $('#<%= params[:id] %>')
    .html('<%= j render "shared/editable_blocks/block_image", block: Block.find(params[:id]) %>');  
<% end %>
