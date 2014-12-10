module.exports =

  create: (post_id, attributes, done, fail) ->
    $.ajax
      url: "/posts/#{post_id}/visibilities"
      type: "POST"
      dataType: "json"
      data:
        visibility: attributes
    .done done
    .fail fail

  update: (id, attributes, done, fail) ->
    $.ajax
      url: "/visibilities/#{id}"
      type: "PUT"
      dataType: "json"
      data:
        visibility: attributes
    .done done
    .fail fail

  destroy: (id, attributes, done, fail) ->
    $.ajax
      url: "/visibilities/#{id}"
      type: "DELETE"
      dataType: "json"
    .done done
    .fail fail
