module.exports =
  
  
  create: (key, attributes, done, fail) ->
    $.ajax
      url:        "/companies/#{key}/people"
      type:       "POST"
      dataType:   "json"
      data:
        person:   attributes
    .done done
    .fail fail
