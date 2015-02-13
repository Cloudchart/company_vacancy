module.exports =
  
  
  create: (key, attributes, done, fail) ->
    data = _.reduce attributes, (memo, value, name) ->
      memo.append("person[#{name}]", value) ; memo
    , new FormData

    $.ajax
      url:          "/companies/#{key}/people"
      type:         "POST"
      dataType:     "json"
      data:         data
      processData:  false
      contentType:  false
    .done done
    .fail fail
  

  update: (key, attributes, done, fail) ->
    
    data = _.reduce attributes, (memo, value, name) ->
      memo.append("person[#{name}]", value) ; memo
    , new FormData
    
    $.ajax
      url:          "/people/#{key}"
      type:         "PUT"
      dataType:     "json"
      data:         data
      processData:  false
      contentType:  false
    .done done
    .fail fail


  destroy: (key, done, fail) ->
    $.ajax
      url:          "/people/#{key}"
      type:         "DELETE"
      dataType:     "json"
    .done done
    .fail fail

