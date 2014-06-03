#
#
#

class Identity extends cc.blueprint.models.Base
  
  @className: 'Identity'

  @attr_accessor 'uuid', 'chart_id', 'node_id', 'identity_id', 'identity_type', 'is_primary'
  
  @instances: {}
  
  @topic: "cc::blueprint::models::identity"


  # Remove identities deleted on server
  #
  @remove_deleted_identities: (chart_id, available_uuids) ->
    identities_to_delete = _.chain(@instances)
      .filter(
        (identity) -> identity.chart_id == chart_id
      )
      .reject(
        (identity) -> _.contains(available_uuids, identity.uuid)
      )
      .invoke('destroy')


  chart: ->
    cc.blueprint.models.Chart.instances[@chart_id]


  node: ->
    cc.blueprint.models.Node.instances[@node_id]
  
  
  identity: ->
    cc.blueprint.models[@identity_type].instances[@identity_id]
  

#
#
#

$.extend cc.blueprint.models,
  Identity: Identity

