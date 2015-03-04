# @cjsx React.DOM

GlobalState       = require('global_state/state')

CompanyStore      = require('stores/company_store.cursor')

Field             = require('components/form/field')
SearchCursorPath  = require('constants').cursors.search

SearchCursor      = GlobalState.cursor(SearchCursorPath)


CompanySearch = React.createClass

  displayName: 'CompanySearch'
  

  # Component specifications
  #
  propTypes:
    query: React.PropTypes.string

  getDefaultProps: ->
    query: ''

  getInitialState: ->
    query: @props.query || location.hash.substr(1) || ''


  # Helpers
  #
  search: (query) ->
    if query.length > 2
      location.hash = "#{@state.query}"
      CompanyStore.search(query)
      SearchCursor.set 'query', query
    else if query.length == 0
      location.hash = ""
      CompanyStore.search(query)
    

  # Handlers
  #
  handleChange: (event) ->
    @search(event.target.value)

    @setState(query: event.target.value)
    

  # Lifecycle methods
  #
  componentDidMount: ->
    @search(@state.query)


  render: ->
   


module.exports = CompanySearch
