module.exports =
  
  
  create: (key, file, done, fail) ->
    data = new FormData ; data.append('picture[image]', file)
    
    $.ajax
      url:          "/blocks/#{key}/picture"
      type:         "POST"
      dataType:     "json"
      data:         data
      contentType:  false
      processData:  false
    .done done
    .fail fail

  update: (key, file, done, fail) ->
    data = new FormData ; data.append('picture[image]', file)
    
    $.ajax
      url:          "/blocks/#{key}/picture"
      type:         "PUT"
      dataType:     "json"
      data:         data
      contentType:  false
      processData:  false
    .done done
    .fail fail
