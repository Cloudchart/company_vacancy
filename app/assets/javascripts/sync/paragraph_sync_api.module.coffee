module.exports =
  
  
  update: (key, attributes, done, fail) ->
    
    $.ajax
      url:          "/blocks/#{key}/paragraph"
      type:         "PATCH"
      dataType:     "json"
      data:
        paragraph:  attributes
    .done done
    .fail fail


  delete: (key, done, fail) ->
    
    $.ajax
      url:          "/blocks/#{key}/paragraph"
      type:         "DELETE"
      dataType:     "json"
    .done done
    .fail fail
