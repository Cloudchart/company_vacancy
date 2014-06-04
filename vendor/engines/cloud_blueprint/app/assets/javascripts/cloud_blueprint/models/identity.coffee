#
#
#

class Identity extends cc.blueprint.models.Base
  
  @className: 'Identity'

  @attr_accessor 'uuid', 'chart_id', 'node_id', 'identity_id', 'identity_type', 'is_primary'
  
  @instances: {}
  
  @created_instances: []
  @deleted_instances: []
  
  # Create identity
  #
  @create: (attributes = {}) ->
    attributes.uuid = @uuid()
    identity = new @(attributes)
    @created_instances.push(identity.uuid)
    identity

#
#
#

$.extend cc.blueprint.models,
  Identity: Identity

