# @cjsx React.DOM

GlobalState   = require('global_state/state')

CompanyStore  = require('stores/company_store.cursor')

Field         = require('components/form/field')


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
  search: ->
    if @state.query
      location.hash = "#{@state.query}"
    else
      location.hash = ""

    CompanyStore.search(@state.query)


  # Handlers
  #
  handleSearch: (query) ->
    @search(query)

  handleChange: (event) ->
    @setState(query: event.target.value)


  # Lifecycle methods
  #
  componentDidMount: ->
    @search(@state.query)


  render: ->
    <div className="search">
      <Field 
        iconClass   = "fa-search"
        placeholder = "Find companies"
        onChange    = { @handleChange }
        onEnter     = { @handleSearch }
        value       = { @state.query }
      />
    </div>


module.exports = CompanySearch
