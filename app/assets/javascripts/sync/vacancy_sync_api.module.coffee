module.exports = 
  
  
  create: (key, attributes, done, fail) ->
    $.ajax
      url:        "/companies/#{key}/vacancies"
      type:       "POST"
      dataType:   "json"
      data:
        vacancy:  attributes
    .done done
    .fail fail
