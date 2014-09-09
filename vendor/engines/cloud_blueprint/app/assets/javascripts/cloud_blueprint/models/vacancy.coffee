VacancyStore = require('stores/vacancy_store')

#
#
#

class Vacancy extends cc.blueprint.models.Base
  
  @className: 'Vacancy'
  
  @attr_accessor  'uuid', 'name', 'description'

  @instances:     {}
  

  # Match for filter
  #
  matches: (letters) ->
    _.any ['name', 'description'], (attribute) => @[attribute].toLowerCase().indexOf(letters) >= 0 if @[attribute]


  # Can be deleted
  #
  can_be_deleted: ->
    super() and _.filter(cc.blueprint.models.Identity.instances, (instance) => instance.identity_id == @uuid).length == 0


#
# Ugly Hack
#

VacancyStore.on 'change', ->
  _.each VacancyStore.all(), (record) ->
    if instance = Vacancy.get(record.to_param())
      instance.set_attributes(record.attr())
    else
      instance = new Vacancy(record.attr())
    instance.synchronize()
    
  Arbiter.publish(Vacancy.broadcast_topic() + '/' + 'update')

#
#
#

$.extend cc.blueprint.models,
  Vacancy: Vacancy
