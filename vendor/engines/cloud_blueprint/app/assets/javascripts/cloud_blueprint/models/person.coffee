class Person extends cc.blueprint.models.Base
  
  @className:     'Person'

  @attr_accessor  'uuid', 'first_name', 'last_name', 'occupation'

  @instances:         {}
  @created_instances: []
  @deleted_instances: []
  
  # Match for filter
  #
  matches: (letters) ->
    _.any ['first_name', 'last_name', 'occupation'], (attribute) => @[attribute].toLowerCase().indexOf(letters) >= 0
  

#
#
#  


$.extend cc.blueprint.models,
  Person: Person
