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
