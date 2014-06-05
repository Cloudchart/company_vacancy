#
#
#

class Vacancy extends cc.blueprint.models.Base
  
  @className: 'Vacancy'
  
  @attr_accessor  'uuid', 'name', 'description'

  @instances:     {}
  
  matches: (letters) ->
    _.any ['name', 'description'], (attribute) => @[attribute].toLowerCase().indexOf(letters) >= 0


#
#
#

$.extend cc.blueprint.models,
  Vacancy: Vacancy
