module.exports =

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
    attributes.tag_names = attributes.tag_names.join(',') if attributes.tag_names

    $.ajax
      url: "/posts/#{key}"
      type: "PUT"
      dataType: "json"
      data:
        post: attributes
    .done done
    .fail fail

  destroy: (key, attributes, done, fail) ->
    $.ajax
      url: "/posts/#{key}"
      type: "DELETE"
      dataType: "json"
    .done done
    .fail fail
