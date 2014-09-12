# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
Actions     = require('cloud_blueprint/actions/server/chart')


# Exports
#
module.exports =
  
  fetch: (key) ->
    done = (Actions.doneFetch || _.noop).bind(null, key)
    fail = (Actions.failFetch || _.noop).bind(null, key)

    Promise.resolve(
      $.ajax
        url:        "/charts/#{key}"
        type:       "GET"
        dataType:   "json"
    ).then(done, fail)
