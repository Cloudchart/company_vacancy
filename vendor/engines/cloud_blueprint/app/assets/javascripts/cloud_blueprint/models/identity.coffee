#
#
#

class Identity extends cc.blueprint.models.Base
  
  @className: 'Identity'

  @attr_accessor 'uuid', 'chart_id', 'node_id', 'identity_id', 'identity_type', 'is_primary'
  
  @instances: {}
  @created_instances: []
  @deleted_instances: []
  

#
#
#

$.extend cc.blueprint.models,
  Identity: Identity
