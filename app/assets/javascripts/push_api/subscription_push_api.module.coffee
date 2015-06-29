module.exports =

  subscribe_guest: (email, options = {}) ->
    Promise.resolve $.ajax
      url: '/guest_subscriptions'
      type:     'POST'
      dataType: 'json'
      data:
        guest_subscription:
          email:  email
