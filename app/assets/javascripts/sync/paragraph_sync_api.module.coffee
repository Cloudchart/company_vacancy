module.exports =


  create: (block_id, attributes, done, fail) ->
    $.ajax
      url:          "/blocks/#{block_id}/paragraph"
      type:         "POST"
      dataType:     "json"
      data:
        paragraph:  attributes
    .done done
    .fail fail

  
  update: (block_id, attributes, done, fail) ->
    $.ajax
      url:          "/blocks/#{block_id}/paragraph"
      type:         "PATCH"
      dataType:     "json"
      data:
        paragraph:  attributes
    .done done
    .fail fail


  destroy: (block_id, done, fail) ->
    $.ajax
      url:          "/blocks/#{block_id}/paragraph"
      type:         "DELETE"
      dataType:     "json"
    .done done
    .fail fail
