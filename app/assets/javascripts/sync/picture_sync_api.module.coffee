module.exports =
  
  
  create: (key, attributes, done, fail) ->
    formData = _.reduce attributes, (memo, value, name) ->
      memo.append("picture[#{name}]", value)
      memo
    , new FormData
    
    $.ajax
      url:          "/blocks/#{key}/picture"
      type:         "POST"
      dataType:     "json"
      data:         formData
      contentType:  false
      processData:  false
    .done done
    .fail fail


  update: (key, attributes, done, fail) ->
    formData = _.reduce attributes, (memo, value, name) ->
      memo.append("picture[#{name}]", value)
      memo
    , new FormData
    
    $.ajax
      url:          "/blocks/#{key}/picture"
      type:         "PUT"
      dataType:     "json"
      data:         formData
      contentType:  false
      processData:  false
    .done done
    .fail fail


  destroy: (key, done, fail) ->
    $.ajax
      url:        "/blocks/#{key}/picture"
      type:       "DELETE"
      dataType:   "json"
    .done done
    .fail fail
