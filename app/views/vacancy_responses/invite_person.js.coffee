<% if @success %>
  $('#<%= @person.id %>').remove()
  $('.vacancy-reviewers').append("<%= j render 'people/person', person: @person, vacancy_id: @vacancy.id %>")
<% end %>
