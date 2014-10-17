NodeIdentityStore = require('cloud_blueprint/stores/node_identity_store')

###
  Used in:

  cloud_blueprint/controllers/chart
  cloud_blueprint/models/chart
  cloud_blueprint/models/person
  cloud_blueprint/models/vacancy
  cloud_blueprint/react/blueprint/chart
  cloud_blueprint/react/blueprint/node
  cloud_blueprint/react/forms/identity_form
  cloud_blueprint/react/forms/node_form
  cloud_blueprint/ujs/node_form_droppable
###

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
