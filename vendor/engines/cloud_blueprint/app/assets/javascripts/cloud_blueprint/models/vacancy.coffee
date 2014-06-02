#
#
#

class Vacancy extends cc.blueprint.models.Base
  
  @attr_accessor  'uuid', 'name', 'description'

  @instances:     {}
  
  matches: (re) ->
    _.any ['name', 'description'], (attribute) => re.test(@[attribute])


#
#
#

$.extend cc.blueprint.models,
  Vacancy: Vacancy
