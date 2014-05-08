vacancy_instances = {}

#
#
#

class Vacancy extends cc.blueprint.models.Base
  
  @attr_accessor  'uuid', 'name', 'description'

  @instances:     {}
  
  @topic:         'cc::blueprint::models::vacancy'
  
  matches: (re) ->
    _.any ['name', 'description'], (attribute) => re.test(@[attribute])


#
#
#

$.extend cc.blueprint.models,
  Vacancy: Vacancy
