###
  Used in:

  cloud_blueprint/controllers/chart
  cloud_blueprint/models/chart
  cloud_blueprint/models/node
  cloud_blueprint/react/identity_filter/buttons
  cloud_blueprint/people/create
  cloud_blueprint/people/destroy
  cloud_blueprint/people/update
###

##= require stores/PersonStore


PersonStore = cc.require('cc.stores.PersonStore')


class Person extends cc.blueprint.models.Base
  
  @className:     'Person'

  @attr_accessor  'uuid', 'full_name', 'first_name', 'last_name', 'email', 'skype', 'phone', 'int_phone', 'occupation', 'bio', 'birthday', 'hired_on', 'fired_on', 'salary'

  @instances:         {}
  @created_instances: []
  @deleted_instances: []
  
  
  # Match for filter
  #
  matches: (letters) ->
    _.any ['first_name', 'last_name', 'occupation'], (attribute) => @[attribute].toLowerCase().indexOf(letters) >= 0 if @[attribute]
  
  
  # Can be deleted
  #
  can_be_deleted: ->
    super() and _.filter(cc.blueprint.models.Identity.instances, (instance) => instance.identity_id == @uuid).length == 0


#
#
#

PersonStore.on 'change', ->
  _.each PersonStore.all(), (record) ->
    if instance = Person.get(record.to_param())
      instance.set_attributes(record.attr())
    else
      instance = new Person(record.attr())
    instance.synchronize()
    
  Arbiter.publish(Person.broadcast_topic() + '/' + 'update')

#
#
#  


$.extend cc.blueprint.models,
  Person: Person
