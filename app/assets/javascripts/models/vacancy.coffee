# Person Class
#
class VacancyModel extends @cc.models.Base
  
  @attr_accessor 'uuid', 'name', 'description'

  @className: 'Vacancy'
    
  @instances:         {}
  @created_instances: []
  @deleted_instances: []
  
  
  matches: (query) ->
    ['name', 'description'].some (attribute_name) =>
      @[attribute_name].toLowerCase().indexOf(query) > -1 if @[attribute_name]
  

# Expose
#
@cc.models.Vacancy = VacancyModel
