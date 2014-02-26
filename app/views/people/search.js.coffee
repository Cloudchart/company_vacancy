<% social_network = params[:social_network].present? ? "#{params[:social_network]}_" : '' %>
$('.search-result').append("<%= j render "#{social_network}people" %>")
