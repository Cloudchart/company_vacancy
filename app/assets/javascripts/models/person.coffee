# Person Class
#
class PersonModel extends @cc.models.Base
  
  @attr_accessor 'uuid', 'first_name', 'last_name', 'occupation'

  @className: 'Person'
    
  @instances:         {}
  @created_instances: []
  @deleted_instances: []
    


# Expose
#
@cc.models.Person = PersonModel
