# @cjsx React.DOM


# Imports
#
Typeahead = require('components/typeahead')

Button    = require('components/form/buttons').StandardButton


# Utils
#
currentFetch  = null

fetchUnicorns = (query, callback) ->
  currentFetch.abort() if currentFetch

  currentFetch = $.ajax
    url: '/api/search'
    type:   'GET'
    dataType:   'json'
    data:
      type:   'Unicorn'
      query:  query

  .done (json) ->
    currentFetch = null
    callback(json) if typeof callback is 'function'

  .fail (xhr) ->
    currentFetch = null
    callback() if typeof callback is 'function'


createUnicorn = (name) ->
  $.ajax
    url:        '/api/unicorns'
    type:       'POST'
    dataType:   'json'
    data:
      unicorn:
        full_name: name


fetchUser = (id, callback) ->
  $.ajax
    url:        '/api/node'
    type:       'GET'
    dataType:   'json'
    data:
      type:     'User'
      id:       id

  .done (json) ->
    callback(json) if typeof callback is 'function'

  .fail (xhr) ->
    callback({}) if typeof callback is 'function'



# Exports
#
module.exports = React.createClass

  displayName: 'UnicornChooser'


  handleUnicornsFetch: (json) ->
    unicorns = Immutable.Seq(json)
      .map (record) ->
        id:     record.id
        value:  record.full_name

    @setState
      unicorns:       unicorns.toArray()
      unicorn_names:  unicorns.map((u) -> u.value.toLowerCase()).toArray()


  handleUserFetch: (json) ->
    @setState
      value:  json.uuid
      query:  json.full_name


  handleDefaultUserFetch: (json) ->
    @setState
      defaultQuery: json.full_name


  handleCreateButtonClick: ->
    name = @state.query.trim()

    createUnicorn(name)
      .done (json) =>
        fetchUser(json.id, @handleUserFetch)


  handleQueryChange: (query) ->
    @setState
      query:  query
      value:  null

    if query.length == 0
      @setState
        unicorns:       []
        unicorn_names:  []
        value:          @props.defaultValue


  handleValueChange: (user) ->
    @setState
      value:  user.id
      query:  user.value


  componentDidMount: ->
    if @state.value
      fetchUser(@state.value, @handleUserFetch)

    if @props.defaultValue
      fetchUser(@props.defaultValue, @handleDefaultUserFetch)



  componentDidUpdate: (prevProps, prevState) ->
    if @state.query.charAt(0) isnt prevState.query.charAt(0)
      fetchUnicorns(@state.query.charAt(0), @handleUnicornsFetch) if @state.query.length > 0

    if @state.value isnt prevState.value
      @props.onChange(@state.value) if typeof @props.onChange is 'function'


  getDefaultProps: ->
    query:          ''
    defaultQuery:   ''
    placeholder:    'Start typing...'


  getInitialState: ->
    unicorns:       []
    value:          @props.value
    query:          @props.query
    defaultQuery:   @props.defaultQuery


  renderCreateButton: ->
    return null if @state.value
    return null unless @state.query
    return null unless @state.query.split(' ').filter((part) -> part).length > 1
    return null if @state.unicorn_names.indexOf(@state.query.trim().toLowerCase()) >= 0

    <Button
      className = "create-button transparent"
      iconClass = "fa fa-plus-circle"
      onClick   = { @handleCreateButtonClick } />


  render: ->
    <div className="unicorn-chooser">
      <Typeahead
        list          = { @state.unicorns }
        query         = { @state.query }
        onQueryChange = { @handleQueryChange }
        onValueChange = { @handleValueChange }
        placeholder   = { @state.defaultQuery || @props.placeholder }
      />
      { @renderCreateButton() }
    </div>
