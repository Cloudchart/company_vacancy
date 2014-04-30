vacancy_instances = {}

#
#
#

class Vacancy extends cc.blueprint.models.Base
  
  @attr_accessor  'uuid', 'name', 'description'

  @instances:     vacancy_instances
  
  @topic:         'cc::blueprint::models::vacancy'
  

#
#
#

$.extend cc.blueprint.models,
  Vacancy: Vacancy
