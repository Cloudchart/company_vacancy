@cc                        ?= {}
@cc.blueprint              ?= {}
@cc.blueprint.datasources  ?= {}

#
#
#

data_source = (url) ->

  deferred  = new $.Deferred

  data      = []

  $.ajax
    url:      url
    type:     'get'
    dataType: 'json'

  .done (result) ->
    data.push(result...)
    deferred.resolve()

  .fail ->
    console.log arguments
  
  deferred.promise(data)
  

$.extend @cc.blueprint.datasources,
  vacancies: data_source
