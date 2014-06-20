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
    _.any ['name', 'description'], (attribute) => @[attribute].toLowerCase().indexOf(letters) >= 0


  # Can be deleted
  #
  can_be_deleted: ->
    super() and _.filter(cc.blueprint.models.Identity.instances, (instance) => instance.identity_id == @uuid).length == 0

#
#
#

$.extend cc.blueprint.models,
  Vacancy: Vacancy
