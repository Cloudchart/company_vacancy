##= require cloud_blueprint/utils/node_identity_sync_api.module

# Imports
#
NodeIdentitySyncAPI = require('cloud_blueprint/utils/node_identity_sync_api')


# Module
#
Module =
  
  destroy: (model) ->
    NodeIdentitySyncAPI.destroy(model)
  

# Exports
#
module.exports = Module
