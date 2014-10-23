# @cjsx React.DOM

# Imports
# 
tag = React.DOM

CompanyStore = require('stores/company')
CompanyActions = require('actions/company')

# Main
# 
Component = React.createClass

  # Helpers
  # 
  getStateFromStores: (props) ->
    company: CompanyStore.get(props.key)
    sync: CompanyStore.getSync(props.key) == 'update'

  # Handlers
  # 
  handleRemoveClick: (event) ->
    CompanyActions.update(@props.key, { slug: '' })

  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->

  componentDidUpdate: (prevProps, prevState) ->
    console.log prevProps
    console.log prevState

  # componentWillUnmount: ->

  # Component Specifications
  # 
  # getDefaultProps: ->

  getInitialState: ->
    @getStateFromStores(@props)

  render: ->
    slugControls = if @state.company.slug
      [
        <span className="label">Short URL</span>
        <span>{@state.company.meta.company_url.split('//').pop()}</span>
      ]

    buttonIcon = <i className={if @state.sync then "fa fa-spinner fa-spin" else "fa fa-eraser"}></i>


    <div className="profile-item">
      <div className="content field">
        {slugControls}
      </div>

      <div className="actions">
        <button className="orgpad alert" onClick={@handleRemoveClick} disabled={@state.sync}>
          <span>Remove</span>
          {buttonIcon}
        </button>
      </div>
    </div>

    # if @state.company.slug
    # else
    

# Exports
# 
module.exports = Component
