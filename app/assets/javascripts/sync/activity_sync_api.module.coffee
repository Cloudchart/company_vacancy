module.exports =
  create: (attributes=null) ->
    return null unless attributes

    data = attributes.reduce (memo, value, name) ->
      memo.append("activity[#{name}]", value); memo
    , new FormData

    Promise.resolve $.ajax
      url: "/activities"
      type: 'POST'
      dataType: 'json'
      processData: false
      contentType: false
      data: data