# @cjsx React.DOM

GlobalState   = require('global_state/state')

CompanyStore  = require('stores/company_store.cursor')

Field         = require('components/form/field')


CompanySearch = React.createClass

  displayName: 'CompanySearch'

  mixins: [GlobalState.mixin]

  # Component specifications
  #
  propTypes:
    query: React.PropTypes.string

  getDefaultProps: ->
    query: ''

  getInitialState: ->
    query: @props.query


  # Handlers
  #
  handleSearch: (query) ->
    CompanyStore.search(query)

  handleChange: (query) ->
    @setState(query: query)


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
