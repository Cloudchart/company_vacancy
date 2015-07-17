# @cjsx React.DOM

# Imports
# 
tag = React.DOM

CompanyStore = require('stores/company')
CompanyActions = require('actions/company')

CloudFluxMixins = require('cloud_flux/mixins')
Constants = require('constants')

# Main
# 
Component = React.createClass

  # Callbacks
  # 
  mixins: [CloudFluxMixins.Actions]

  getCloudFluxActions: ->
    actions = {}
    actions[Constants.Company.UPDATE_DONE] = @onUpdateDone
    actions

  onUpdateDone: (key, json, token) ->
    window.location.href = (json.meta.settings_url + "#settings") if token == 'slug'

  # Helpers
  #     
  update: (slug) ->
    CompanyActions.update(@props.uuid, { slug: slug }, 'slug')

  getStateFromStores: (props) ->
    company = CompanyStore.get(props.uuid)

    company: company
    value: company.slug
    sync: CompanyStore.getSync(props.uuid) == 'slug'

  # Handlers
  # 
  handleRemoveClick: (event) ->
    @update('')

  handleSlugOnChange: (event) ->
    @setState({ value: event.target.value })

  handleSlugKeyUp: (event) ->
    switch event.key
      when 'Enter'
        @update(@state.value) if @state.value
      when 'Escape'
        @setState({ value: '' })

  handleSaveClick: (event) ->
    @update(@state.value) if @state.value

  # Lifecycle Methods
  # 
  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  # Component Specifications
  # 
  getInitialState: ->
    @getStateFromStores(@props)

  render: ->
    if @state.company.slug
      <div className="profile-item">

        <div className="content field">
          <span className="label">Short URL</span>
          <div className="spacer"></div>
          <span>{window.location.hostname + '/companies/' + @state.company.slug}</span>
        </div>

        <div className="actions">
          <button className="orgpad alert" onClick={@handleRemoveClick} disabled={@state.sync}>
            <span>Remove</span>
            <i className={if @state.sync then "fa fa-spinner fa-spin" else "fa fa-eraser"}></i>
          </button>
        </div>
      </div>

    else
      <div className="profile-item">
        
        <div className="content field">
          <label htmlFor="slug">Short URL</label>
          <div className="spacer"></div>
          <span>{window.location.hostname + '/companies/'}</span>
          <input id="slug" name="slug" value={@state.value} placeholder="shortname" onKeyUp={@handleSlugKeyUp} onChange={@handleSlugOnChange}></input>
        </div>

        <div className="actions">
          <button className="orgpad" onClick={@handleSaveClick} disabled={@state.sync}>
            <span>Save</span>
            <i className={if @state.sync then "fa fa-spinner fa-spin" else "fa fa-save"}></i>
          </button>
        </div>
      </div>

# Exports
# 
module.exports = Component
