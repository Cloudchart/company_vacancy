# Cache
#
cachedPromises = {}

# Exports
#
module.exports =

  fetchOne: (id, params = {}, options = {}) ->
    url = '/tokens/' + id
    
    delete cachedPromises[url] if options.force == true

    cachedPromises[url] ||= Promise.resolve $.ajax
      url: url
      type: "GET"
      dataType: "json"
      data: params

  createGreeting: (user, params, options) ->
    Promise.resolve $.ajax
      url: "/users/#{user.get('uuid')}/greeting"
      type: 'POST'
      dataType: 'json'
      data: params

  updateGreeting: (id, params, options) ->
    Promise.resolve $.ajax
      url: "/user_greeting/#{id}"
      type: 'PUT'
      dataType: 'json'
      data: params

  destroyGreeting: (id, params, options) ->
    Promise.resolve $.ajax
      url: "/user_greeting/#{id}"
      type: 'DELETE'
      dataType: 'json'
      data: params

  destroyWelcomeTour: (id, params, options) ->
    Promise.resolve $.ajax
      url: "/user_welcome_tour/#{id}"
      type: 'DELETE'
      dataType: 'json'
      data: params

  destroyInsightTour: (id, params, options) ->
    Promise.resolve $.ajax
      url: "/user_insight_tour/#{id}"
      type: 'DELETE'
      dataType: 'json'
      data: params
