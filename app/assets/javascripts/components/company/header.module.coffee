# @cjsx React.DOM

# Imports
#
tag = React.DOM

GlobalState   = require('global_state/state')
CompanyStore  = require('stores/company')

CompanyActions  = require('actions/company')
ModalActions    = require('actions/modal_actions')

AutoSizingInput = require('components/form/autosizing_input')
FollowComponent = require('components/company/follow')
AccessRights    = require('components/company/access_rights')
TagsComponent   = require('components/company/tags')

TempKVStore     = require('utils/temp_kv_store')

# Main
#
Component = React.createClass

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
    <FollowComponent key={@props.id}, is_followed={@state.cursor.flags.get('is_followed')} />

  update: (attr_name) ->
    return if @props.readOnly

    attributes = {}
    attributes[attr_name] = @state[attr_name]

    CompanyActions.update(@props.id, attributes)

  
  updateLogotype: (file) ->
    return if @props.readOnly

    CompanyActions.update(@props.id, { logotype: file })


  # Handlers
  # 
  handleRemoveLogotype: ->
    return if @props.readOnly

    CompanyActions.update(@props.id, { logotype_url: null, remove_logotype: true })

  handleShareClick: (event) ->
    event.preventDefault()

    if TempKVStore.get("invitable_contacts")
      ModalActions.show(<AccessRights uuid={@props.id} />)
    else
      @setState(shareLoading: true)
      CompanyActions.fetchAccessRights(@props.id)

      TempKVStore.on "invitable_contacts_changed", =>
        setTimeout =>
          @setState(shareLoading: false)
          ModalActions.show(<AccessRights uuid={@props.id} />)
          TempKVStore.off "invitable_contacts_changed"

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

  # Lifecycle Methods
  # 
  componentWillReceiveProps: (nextProps) ->
    URL.revokeObjectURL(@state.logotype_url)
    @setState(@getStateFromStores(nextProps))

  # Component Specifications
  # 
  getStateFromStores: (props) ->
    company = CompanyStore.get(props.id)

    company: company
    name: company.name
    description: company.description
    logotype_url: company.logotype_url

  getInitialState: ->
    _.extend @getStateFromStores(@props),
      shareLoading: false
      cursor:
        flags: GlobalState.cursor(['stores', 'companies', 'flags', @props.id])

  render: ->
    <header>
      {@getViewModeSelect()}
      {@getLogo()}

      <label className="name">
        <AutoSizingInput
          value={@state.name}
          onBlur={@handleFieldBlur.bind(@, 'name')}
          onChange={@handleFieldChange.bind(@, 'name')}
          onKeyUp={@handleFieldKeyUp}
          placeholder={'Company name'}
          readOnly={@props.readOnly}
        />

        {@getShareLink()}
      </label>

      <label className="description">
        <AutoSizingInput
          value={@state.description}
          onBlur={@handleFieldBlur.bind(@, 'description')}
          onChange={@handleFieldChange.bind(@, 'description')}
          onKeyUp={@handleFieldKeyUp}
          placeholder={'Company short description'}
          readOnly={@props.readOnly}
        />
      </label>

      <TagsComponent taggable_id={@props.id} taggable_type="Company" readOnly={@props.readOnly} />
      {@getFollowButoon()}
    </header>


# Exports
#
module.exports = Component
