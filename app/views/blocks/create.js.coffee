transition = $('<div>').addClass('transition').html('<%= j render partial: "shared/block", object: @block -%>')

<% if @block.position == 0 %>
$('section[data-name="<%= @block.section %>"]').append(transition)
<% else %>
$('.identity-block', 'section[data-name="<%= @block.section %>"]').eq(<%= @block.position - 1 %>).after(transition)
<% end %>

rectangle = transition[0].getBoundingClientRect()

transition.css
  height:   0
  overflow: 'hidden'

transition.animate
  height: rectangle.height
,
  duration: 500
  complete: ->
    transition.children().unwrap()