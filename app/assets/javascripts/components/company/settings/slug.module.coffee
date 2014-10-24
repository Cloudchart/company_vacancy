# @cjsx React.DOM

# Imports
# 
tag = React.DOM

CompanyStore = require('stores/company')
CompanyActions = require('actions/company')

# CloudFlux = require('cloud_flux')
# Constants = require('constants')

# Main
# 
Component = React.createClass

  # Helpers
  # 
  gatherContent: ->
    if @state.company.slug
      <div className="content field">
        <span className="label">Short URL</span>
        <span>{window.location.hostname + '/companies/' + @state.company.slug}</span>
      </div>
    else
      <div className="content field">
        <label htmlFor="slug">Short URL</label>
        <div className="spacer"></div>
        <span>{window.location.hostname + '/companies/'}</span>
        <input id="slug" name="slug" value={@state.value} placeholder="shortname" onKeyUp={@handleSlugKeyUp} onChange={@handleSlugOnChange}></input>
      </div>

  gatherActions: ->
    if @state.company.slug
      <button className="orgpad alert" onClick={@handleRemoveClick} disabled={@state.sync}>
        <span>Remove</span>
        <i className={if @state.sync then "fa fa-spinner fa-spin" else "fa fa-eraser"}></i>
      </button>
    else
      <button className="orgpad" onClick={@handleSaveClick} disabled={@state.sync}>
        <span>Save</span>
        <i className={if @state.sync then "fa fa-spinner fa-spin" else "fa fa-save"}></i>
      </button>
    

  getStateFromStores: (props) ->
    company = CompanyStore.get(props.key)

    company: company
    value: company.slug
    sync: CompanyStore.getSync(props.key) == 'update'

  # Handlers
  # 
  update: (slug) ->
    CompanyActions.update(@props.key, { slug: slug })

  handleRemoveClick: (event) ->
    @update('')

  handleSlugOnChange: (event) ->
    @setState({ value: event.target.value })

  handleSlugKeyUp: (event) ->
    switch event.key
      when 'Enter'
        @update(@state.value) #unless @state.company.slug == @state.value
      when 'Escape'
        @setState({ value: '' })

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
    <div className="profile-item">
      
      {@gatherContent()}

      <div className="actions">
        {@gatherActions()}
      </div>
    </div>

# Exports
# 
module.exports = Component
