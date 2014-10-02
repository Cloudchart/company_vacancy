module.exports =

  update: (key, attributes, done, fail) ->
    
    $.ajax
      url:          "/blocks/#{key}"
      type:         "PATCH"
      dataType:     "json"
      data:
        block:      attributes
    .done done
    .fail fail
