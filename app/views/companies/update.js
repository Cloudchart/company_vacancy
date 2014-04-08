<% if params[:company][:logo_attributes].present? %>
  $('nav[data-behaviour~="editable-article-nav"] li.logo')
    .html('<%= j render "shared/companies/logo_remote_form", company: Company.find(params[:id]) %>');
<% end %>
