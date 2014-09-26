module.exports =
  

  fetch: (done, fail) ->
    $.ajax
      url:      "/tags"
      type:     "GET"
      dataType: "json"
    .done done
    .fail fail


  create: (data, done, fail) ->
    $.ajax
      url:        "/tags"
      type:       "POST"
      dataType:   "json"
      data:
        tag:      data
    .done done
    .fail fail
