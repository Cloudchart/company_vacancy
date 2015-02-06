pendingPromises = {}

module.exports =

  fetchOne: (id, params = {}, options = {}) ->
    delete pendingPromises["fetchOne" + id] if options.force == true

    pendingPromises["fetchOne" + id] ||= Promise.resolve $.ajax
      url:        "/quotes/" + id
      dataType:   "json"
      cache:      false
      data:       params


  create: (attributes, done, fail) ->
    Promise.resolve $.ajax
      url:      "/blocks/#{attributes.block_id}/quote"
      type:     "POST"
      dataType: "json"
      data:
        quote:    attributes

  
  update: (quote, attributes, done, fail) ->
    block_id = quote.get("owner_id")

    Promise.resolve $.ajax
      url:      "/blocks/#{block_id}/quote"
      type:     "PATCH"
      dataType: "json"
      data:
        quote:    attributes
