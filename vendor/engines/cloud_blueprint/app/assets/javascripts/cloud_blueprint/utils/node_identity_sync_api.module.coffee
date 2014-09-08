# Imports
#
NodeIdentityServerActions = require('cloud_blueprint/actions/server/node_identity_actions')

# Module
#
Module = 


  # Fetch
  #
  fetch: (url) ->
    Promise.resolve(
      $.ajax
        url:        url
        type:       "GET"
        dataType:   "json"
    ).then(NodeIdentityServerActions.fetchDone, NodeIdentityServerActions.fetchFail)
  
  
  # Destroy
  #
  destroy: (model) ->
    Promise.resolve(
      $.ajax
        url:        "/charts/#{model.attr('chart_id')}/identities/#{model.to_param()}"
        type:       "DELETE"
        dataType:   "json"
    ).then(NodeIdentityServerActions.destroyDone.bind(null, model), NodeIdentityServerActions.destroyFail.bind(null, model))
  

# Exports
#
module.exports = Module
