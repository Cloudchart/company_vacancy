module.exports =

  subscribe_guest: (email, options = {}) ->
    Promise.resolve $.ajax
      url: '/'
      type:     'POST'
      dataType: 'json'
      data:
        email:  email
