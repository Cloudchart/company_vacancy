module.exports =

  create: (attributes, options = {}) ->
    Promise.resolve $.ajax
      url: '/device_tokens'
      method: 'POST'
      data:
        device_token: attributes
      dataType: 'json'
