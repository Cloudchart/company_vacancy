people_instances = {}

#
#
#

class Person extends cc.blueprint.models.Base

  @attr_accessor  'uuid', 'first_name', 'last_name', 'occupation'

  @instances:     people_instances
  
  @topic:         'cc::blueprint::models::person'
  
  matches: (re) ->
    _.any ['first_name', 'last_name', 'occupation'], (attribute) => re.test(@[attribute])
  

#
#
#  


$.extend cc.blueprint.models,
  Person: Person
