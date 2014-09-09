VacancyStore  = require('stores/vacancy_store')
VSA           = require('actions/server/vacancy_actions')

# Module
#
Module =
  
  
  # Fetch
  #
  fetch: (url) ->
    Promise.resolve(
      $.ajax
        url:        url
        type:       "GET"
        dataType:   "json"
    ).then(VSA.fetchDone, VSA.fetchFail)
  
  
  # Create
  #
  create: (model) ->
    Promise.resolve(
      $.ajax
        url:        "/companies/#{model.attr('company_id')}/vacancies"
        type:       "POST"
        dataType:   "JSON"
        data:
          vacancy:  model.attr()
    ).then(VSA.createDone.bind(null, model), VSA.createFail.bind(null, model))
  
  
  # Update
  #
  update: (model) ->
    Promise.resolve(
      $.ajax
        url:        "/vacancies/#{model.to_param()}"
        type:       "PUT"
        dataType:   "json"
        data:
          vacancy:  model.attr()
    ).then(VSA.updateDone.bind(null, model), VSA.updateFail.bind(null, model))
  

# Exports
#
module.exports = Module
