module.exports =

  # TODO: write base CRUD, something like only: [:create, :update, :destroy]
  # do we really need sync api? can we put it in actions for simplicity?

  fetchAll: (company_id, done, fail) ->
    $.ajax
      url:        "/companies/#{company_id}/posts"
      type:       "GET"
      dataType:   "json"
    .done done
    .fail fail

  create: (company_id, attributes, done, fail) ->
    $.ajax
      url: "/companies/#{company_id}/posts"
      type: "POST"
      dataType: "json"
      data:
        post: attributes
    .done done
    .fail fail

  update: (key, attributes, done, fail) ->
    $.ajax
      url: "/posts/#{key}"
      type: "PUT"
      dataType: "json"
      data:
        post: attributes
    .done done
    .fail fail

  delete: (key, done, fail) ->
    $.ajax
      url: "/posts/#{key}"
      type: "DELETE"
      dataType: "json"
    .done done
    .fail fail
