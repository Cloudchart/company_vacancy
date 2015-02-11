# Query parser
#
parseQuery = (query) ->
  result    = Immutable.Map()

  return result unless query and query.length > 0

  key       = ''
  count     = 0
  subquery  = ''


  result = result.withMutations (result) ->
    Immutable.Seq(query).forEach (char) ->
      switch char
        when '{'
          subquery += char if count > 0
          count++
        when '}'
          count--
          subquery += char if count > 0
          if count == 0
            result.set(key, parseQuery(subquery))
            subquery = ''
        when ','
          if count > 0
            subquery += char
          else
            result.set(key, null) unless result.has(key)
            key = ''
        else
          if count > 0 then subquery += char else key += char

    result.set(key, null) unless result.has(key)

  result


# Stringify query
#
stringifyQuery = (query) ->
  return '' unless query

  query

    .sortBy (value, key) -> key

    .reduce (memo, value, key) ->
      memo.add key + if value = stringifyQuery(value) then "{#{value}}" else ''
    , Immutable.Set().asMutable()

    .join(',')



# Query model
#
class Query

  constructor: (value) ->
    query       = parseQuery(value.replace(/\s+/g, ''))

    @endpoint   = query.keySeq().first()
    @query      = query.get(@endpoint)


  toString: ->
    stringifyQuery(@query)


# Exports
#
module.exports =

  Query: Query

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
