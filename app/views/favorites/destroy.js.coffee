$("#<%= @favorite.favoritable_id %>")
  .find('.favorites-link')
  .html("<%= j render 'shared/favorites_link', object: @favorite.favoritable %>")
