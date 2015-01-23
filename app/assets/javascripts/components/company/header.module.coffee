# @cjsx React.DOM

# Imports
#
tag = React.DOM

CloudFlux           = require('cloud_flux')
GlobalState         = require('global_state/state')

CompanyStore        = require('stores/company')

CompanyActions      = require('actions/company')
ModalActions        = require('actions/modal_actions')

AutoSizingInput     = require('components/form/autosizing_input')
FollowComponent     = require('components/company/follow')
Checkbox            = require('components/form/checkbox')
AccessRights        = require('components/company/access_rights')
TagsComponent       = require('components/company/tags')
ContentEditableArea = require('components/form/contenteditable_area')

# Main
#
Component = React.createClass

  mixins: [CloudFlux.mixins.Actions]

  # Helpers
  # 
  getViewModeSelect: ->
    return null unless @props.shouldDisplayViewMode

    <div className="controls">
      <label className="cc-toggle view-mode">
        <input type="checkbox" checked={not @props.readOnly} onChange={@handleViewModeChange} />
        <span>
          <span className="off">View</span>
          <i></i>
          <span className="on">Edit</span>
        </span>
      </label>
    </div>

  
  getLogoBackgroundImage: ->
    if @state.logotype_url then "url(#{@state.logotype_url})" else "none"
  
  getLogo: ->
    return null if @props.readOnly and !@state.logotype_url

    uploader = if @props.readOnly
      null
    else
      placeholder = if @state.logotype_url
        null
      else
        <div className="placeholder">
          <i className="fa fa-picture-o"></i>
          <span>Tap to add logo</span>
        </div>

      <label>
        {placeholder}
        <input type="file" name="" onChange={@handleLogotypeChange}></input>
      </label>

    remove_button = if @props.readOnly or !@state.logotype_url
      null
    else
      <i className="fa fa-times remove" onClick={@handleRemoveLogotype}></i>

    return(
      <aside className="logo" style={backgroundImage: @getLogoBackgroundImage()}>
        {uploader}
        {remove_button}
      </aside>
    )


  getShareLink: ->
    return null if @props.readOnly

    <a href="" className="share-link" onClick={@handleShareClick}>
      {
        if !@state.shareLoading
          <i className="fa fa-share"></i>
        else
          <i className="fa fa-spinner fa-spin"></i>
      }
    </a>


  getFollowButoon: ->
    return null unless @state.cursor.flags.get('can_follow')
    <FollowComponent key={@props.uuid}, is_followed={@state.cursor.flags.get('is_followed')} />

  update: (attr_name) ->
    return if @props.readOnly

    attributes = {}
    attributes[attr_name] = @state[attr_name]

    CompanyActions.update(@props.uuid, attributes)

  
  updateLogotype: (file) ->
    return if @props.readOnly
    CompanyActions.update(@props.uuid, { logotype: file })


  getCloudFluxActions: ->
    'company:access_rights:fetch:done': @handleAccessRightsDone


  # Handlers
  # 
  handleAccessRightsDone: -> 
    setTimeout =>
      @setState(shareLoading: false)
      ModalActions.show(<AccessRights uuid={@props.uuid} />)
    

  handleRemoveLogotype: ->
    return if @props.readOnly
    CompanyActions.update(@props.uuid, { logotype_url: null, remove_logotype: true })


  handleShareClick: (event) ->
    event.preventDefault()

    if GlobalState.cursor(['flags', 'companies']).get('isAccessRightsLoaded')
      ModalActions.show(<AccessRights uuid={@props.uuid} />)
    else
      @setState(shareLoading: true)
      CompanyActions.fetchAccessRights(@props.uuid)


  handleFieldBlur: (attr_name, event) ->
    @update(attr_name) unless @state[attr_name] == @state.company[attr_name]

  handleFieldChange: (name, event) ->
    state = {}
    state[name] = event.target.value
    @setState(state)
  
  handleLogotypeChange: (event) ->
    file = event.target.files[0]
    @setState({ logotype_url: URL.createObjectURL(file) })
    @updateLogotype(file)

  handleViewModeChange: (event) ->
    readOnly = not event.target.checked
    @props.onChange({ readOnly: readOnly })
  
  handleFieldKeyUp: (event) ->
    event.target.blur() if event.key == 'Enter'

  handleDescriptionChange: (content) ->
    return if @state.company.description is content or @props.readOnly
    CompanyActions.update(@props.uuid, { description: content })

  onIsNameInLogoChange: (value) ->
    CompanyActions.update(@props.uuid, { is_name_in_logo: value })

  # Lifecycle Methods
  # 
  componentWillReceiveProps: (nextProps) ->
    URL.revokeObjectURL(@state.logotype_url)
    @setState(@getStateFromStores(nextProps))


  # Component Specifications
  # 
  getStateFromStores: (props) ->
    company = CompanyStore.get(props.uuid)

    company: company
    name: company.name
    logotype_url: company.logotype_url

  getInitialState: ->
    _.extend @getStateFromStores(@props),
      shareLoading: false
      cursor:
        flags: GlobalState.cursor(['stores', 'companies', 'flags', @props.uuid])

  render: ->
    <header>
      { @getViewModeSelect() }
      { @getLogo() }

      {
        if @state.company.logotype_url && !@props.readOnly
          <Checkbox 
            customClass      = "is-name-in-logo"
            checked          = { @state.company.is_name_in_logo }
            iconClass        = "fa-chain-broken"
            iconCheckedClass = "fa-link"
            onChange         = { @onIsNameInLogoChange }
          />
      }

      {
        if !@state.company.is_name_in_logo || !@props.readOnly
          <label className="name">
              <AutoSizingInput
                disabled = { @state.company.is_name_in_logo }
                value = { @state.name }
                onBlur = { @handleFieldBlur.bind(@, 'name') }
                onChange = { @handleFieldChange.bind(@, 'name') }
                onKeyUp = { @handleFieldKeyUp }
                placeholder = 'Company name'
                readOnly = { @props.readOnly }
              />

            { @getShareLink() }
          </label>
      }

      <label className="description">
        <ContentEditableArea
          onChange = { @handleDescriptionChange }
          placeholder = 'Company short description'
          readOnly = { @props.readOnly }
          value = { @state.company.description }
        />
      </label>

      <TagsComponent 
        taggable_id = { @props.uuid }
        taggable_type = 'Company'
        readOnly = { @props.readOnly }
      />
      
      { @getFollowButoon() }
    </header>


# Exports
#
module.exports = Component
