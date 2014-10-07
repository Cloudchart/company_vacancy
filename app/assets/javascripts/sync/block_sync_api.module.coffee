module.exports =

  update: (key, attributes, done, fail) ->
    
    if attributes['identity_ids'] and attributes['identity_ids'].length == 0
      attributes['clear_identity_ids'] = true
      delete attributes['identity_ids']
    
    $.ajax
      url:          "/blocks/#{key}"
      type:         "PATCH"
      dataType:     "json"
      data:
        block:      attributes
    .done done
    .fail fail
