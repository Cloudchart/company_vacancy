# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = (component, descriptor) ->

  React.createClass


    displayName: component.displayName + 'CloudRelayContainer'


    getContainerProps: ->
      props =
        queryParams:      @state.queryParams
        setQueryParams:   @setQueryParams

      props


    getQuery: (name) ->
      new GlobalState.query.Query(@state.queries.get(name)(@state.queryParams))


    setQueryParams: (params = {}) ->
      @setState
        queryParams: Immutable.Map(@state.queryParams).mergeDeep(params).toJS()


    gatherRelayedObjects: ->
      Immutable.fromJS(descriptor.queries).map (body, name) =>
        if @props[name] and typeof @props[name] isnt "string"
          @props[name]
        else
          GlobalState.fetch(@getQuery(name), { id: @props[name] })


    componentWillMount: ->
      @setState
        relayedObjects: @gatherRelayedObjects()


    getInitialState: ->
      queryParams:      descriptor.queryParams || {}
      queries:          Immutable.Seq(descriptor.queries)


    render: ->
      React.createElement(component, Object.assign({}, @props, @getContainerProps()))
