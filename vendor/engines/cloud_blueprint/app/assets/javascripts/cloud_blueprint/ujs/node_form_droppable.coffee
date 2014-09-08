NodeIdentityStore     = require('cloud_blueprint/stores/node_identity_store')
NodeIdentityActions   = require('cloud_blueprint/actions/node_identity_actions')

#
#
#

# On enter
#
on_enter = (event) ->
  return unless event.dataTransfer or event.dataTransfer.types.indexOf('identity') == -1

  node              = cc.blueprint.models.Node.get(event.target.dataset.id)
  identity_data     = JSON.parse(event.dataTransfer.getData('identity'))
  people_uuids      = node.people().map((person) -> person.uuid)
  vacancies_uuids   = node.vacancies().map((vacancy) -> vacancy.uuid)
  captured          = people_uuids.indexOf(identity_data.uuid) < 0 and vacancies_uuids.indexOf(identity_data.uuid) < 0

  event.dataTransfer.setData('captured', captured)
  event.target.classList.toggle('captured', captured)
    

# On leave
#
on_leave = (event) ->
  return unless event.dataTransfer or event.dataTransfer.types.indexOf('identity') == -1

  event.dataTransfer.clearData('captured')
  event.target.classList.remove('captured')


# On drop
#
on_drop = (event) ->
  return unless event.dataTransfer or event.dataTransfer.types.indexOf('identity') == -1

  event.target.classList.remove('captured')

  identity_data   = JSON.parse(event.dataTransfer.getData('identity'))
  nodeModel       = cc.blueprint.models.Node.get(event.target.dataset.id)


  nodeIdentity = new NodeIdentityStore
    chart_id:       nodeModel.chart_id
    node_id:        nodeModel.uuid
    identity_id:    identity_data.uuid
    identity_type:  identity_data.className
  
  NodeIdentityActions.create(nodeIdentity)  

  # identity_data   = JSON.parse(event.dataTransfer.getData('identity'))
  # identity_model  = cc.blueprint.models[identity_data.className].get(identity_data.uuid)
  #
  # identity = cc.blueprint.models.Identity.create
  #   chart_id:       identity_model.chart_id
  #   node_id:        event.target.dataset.id
  #   identity_id:    identity_data.uuid
  #   identity_type:  identity_data.className
  #
  # identity.save()
  

#
# Observer
#

observer = (container, selector) ->
  
  $container = $(container)
  
  $container.on 'cc::drag:drop:enter', selector, on_enter
  $container.on 'cc::drag:drop:leave', selector, on_leave
  $container.on 'cc::drag:drop:drop',  selector, on_drop


#
#
#

_.extend cc.blueprint.common,
  node_form_droppable: observer
