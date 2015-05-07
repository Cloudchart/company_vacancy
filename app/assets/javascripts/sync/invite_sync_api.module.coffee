cachedPromises = {}

# Exports
#
module.exports =
  create: (attributes=null) ->
    if attributes
      data = attributes.reduce (memo, value, name) ->
        memo.append("user[#{name}]", value); memo
      , new FormData

    Promise.resolve $.ajax
      url: "/invites"
      type: 'POST'
      dataType: 'json'
      processData: false
      contentType: false
      data: data

  send_email: (user, attributes=null) ->
    if attributes
      data = attributes.reduce (memo, value, name) ->
        memo.append("email_template[#{name}]", value); memo
      , new FormData

    Promise.resolve $.ajax
      url: "/invites/#{user.get('uuid')}/email"
      type: 'PUT'
      dataType: 'json'
      processData: false
      contentType: false
      data: data