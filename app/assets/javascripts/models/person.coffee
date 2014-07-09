# Person Class
#
class PersonModel extends @cc.models.Base
  
  @attr_accessor 'uuid', 'first_name', 'last_name', 'occupation'

  @className: 'Person'
    
  @instances:         {}
  @created_instances: []
  @deleted_instances: []
  
  
  matches: (query) ->
    ['first_name', 'last_name', 'occupation'].some (attribute_name) =>
      @[attribute_name].toLowerCase().indexOf(query) > -1 if @[attribute_name]
  

  initials: ->
    ['first_name', 'last_name'].map (attribute_name) =>
      @[attribute_name].charAt(0).toUpperCase() if @[attribute_name]
    .join('')
  

  initials_hash: ->
    @initials().split('').reduce ((memo, letter) -> memo + letter.charCodeAt(0)), 0
    


# Expose
#
@cc.models.Person = PersonModel
