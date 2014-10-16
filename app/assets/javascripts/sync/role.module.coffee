# Exports
#
module.exports =

  update: (key, attributes, done, fail) ->
    $.ajax
      url:        "/roles/#{key}"
      type:       "PATCH"
      dataType:   "json"
      data:       { role: attributes }
    .done done
    .fail fail
  
  delete: (key, done, fail) ->
    $.ajax
      url:        "/roles/#{key}"
      type:       "DELETE"
      dataType:   "json"
    .done done
    .fail fail
