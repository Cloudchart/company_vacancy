module.exports =

  update: (key, attributes, done, fail) ->
    
    formData = _.reduce attributes, (memo, value, name) ->
      memo.append(name, value)
      memo
    , new FormData
    
    $.ajax
      url:          "/blocks/#{key}"
      type:         "PATCH"
      dataType:     "json"
      data:         formData
      contentType:  false
      processData:  false
    .done done
    .fail fail
