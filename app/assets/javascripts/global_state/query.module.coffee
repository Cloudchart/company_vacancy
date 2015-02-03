query = require('utils/query')

class Query

  constructor: (value) ->
    {@model, @relations} = query.get(value)


  toString: ->
    @relations.replace(/\s+/g, '')


# Exports
#
module.exports =

  mixin:

    statics:

      getQuery: (name) ->
        unless @queries[name]
          throw new Error("GlobalState/Query: #{@displayName} doesn't have #{name} query.")

        unless @queries[name] instanceof Function
          throw new Error("GlobalState/Query: #{@displayName} #{name} query should be a function.")

        new Query(@queries[name]())


    getQuery: ->
      @constructor.getQuery.apply(@constructor, arguments)
