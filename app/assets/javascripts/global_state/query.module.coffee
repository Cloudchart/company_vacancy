# Query parser
#


PEG_RULE = """

start =
  endpoint


endpoints =
  first:endpoint ',' rest:endpoints {
    Immutable.Seq(rest).forEach(function(item, key) {
      first[key] = (Immutable.fromJS(first[key]) || Immutable.Map()).mergeDeep(item).toJS()
    })
    return first
  }
  / only:endpoint {
    return only
  }


endpoint =
  space? identifier:identifier id:id? space? children:children? space? {
    result              = {}
    result[identifier]  = {}

    if (id)
      result[identifier].id = id

    if (children)
      result[identifier].children = children

    return result
  }


children =
  '{' endpoints:endpoints? '}' {
    return endpoints
  }


identifier =
  first:[a-zA-Z_]+ rest:[a-zA-Z0-9_]* {
    return first.join('') + rest.join('')
  }


id =
  '(' letters:[a-zA-Z0-9_\-]+ ')' {
    return letters.join('')
  }


space =
  [ \\t\\n\\r]+


"""

Parser = PEG.buildParser(PEG_RULE)


stringifyQuery = (query) ->
  return '' unless (children = query.get('children', false)) and children.size > 0

  Immutable.List()

    .withMutations (data) ->
      children

        .sortBy (child_query, key) ->
          key

        .forEach (child_query, key) ->
          data.push key + if child = stringifyQuery(child_query) then "{#{child}}" else ''

    .join(',')


class Query

  @stringify: stringifyQuery

  constructor: (query, options = {}) ->
    query     = Immutable.fromJS(Parser.parse(query))
    @endpoint = query.keySeq().first()
    @id       = query.getIn([@endpoint, 'id'])
    @query    = query.get(@endpoint)


  toString: ->
    stringifyQuery(@query)


# Exports
#
module.exports =

  Query: Query

  mixin:

    statics:

      getQuery: (name, params = {}) ->
        unless @queries[name]
          throw new Error("GlobalState/Query: #{@displayName} doesn't have #{name} query.")

        unless @queries[name] instanceof Function
          throw new Error("GlobalState/Query: #{@displayName} #{name} query should be a function.")

        new Query(@queries[name](params))


    getQuery: ->
      @constructor.getQuery.apply(@constructor, arguments)
