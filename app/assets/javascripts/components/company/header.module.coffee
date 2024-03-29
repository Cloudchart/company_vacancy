# @cjsx React.DOM

# Imports
#
tag = React.DOM
cx  = React.addons.classSet

GlobalState         = require('global_state/state')

CompanyStore        = require('stores/company')

CompanyActions      = require('actions/company')
ModalActions        = require('actions/modal_actions')

AutoSizingInput     = require('components/form/autosizing_input')
FollowComponent     = require('components/company/follow')
Checkbox            = require('components/form/checkbox')
Toggle              = require('components/form/toggle')
TagsComponent       = require('components/company/tags')
ContentEditableArea = require('components/form/contenteditable_area')
InviteActions       = require('components/roles/invite_actions')

ShareButtons        = require('components/shared/share_buttons')

# Main
#
Component = React.createClass

  # Helpers
  #
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

  getNameClass: ->
    cx(name: true, inactive: @state.company.is_name_in_logo)

  getFollowButton: ->
    return null unless @state.cursor.flags.get('can_follow')
    <FollowComponent uuid={@props.uuid}, is_followed={@state.cursor.flags.get('is_followed')} />

  update: (attr_name) ->
    return if @props.readOnly

    attributes = {}
    attributes[attr_name] = @state[attr_name]

    CompanyActions.update(@props.uuid, attributes)

  
  updateLogotype: (file) ->
    return if @props.readOnly
    CompanyActions.update(@props.uuid, { logotype: file })


  # Handlers
  # 
  handleRemoveLogotype: ->
    return if @props.readOnly
    CompanyActions.update(@props.uuid, { logotype_url: null, remove_logotype: true })

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
  
  handleFieldKeyUp: (event) ->
    event.target.blur() if event.key == 'Enter'

  handleDescriptionChange: (content) ->
    return if @state.company.description is content or @props.readOnly
    CompanyActions.update(@props.uuid, { description: content })

  onIsNameInLogoChange: (value) ->
    CompanyActions.update(@props.uuid, { is_name_in_logo: value })


  # Lifecycle Methods
  # 
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)

  componentWillReceiveProps: (nextProps) ->
    URL.revokeObjectURL(@state.logotype_url)
    @setState(@getStateFromStores(nextProps))

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)


  # Component Specifications
  # 
  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    company = CompanyStore.get(props.uuid)

    company: company
    name: company.name if company
    logotype_url: company.logotype_url if company

  getInitialState: ->
    _.extend @getStateFromStores(@props),
      shareLoading: false
      cursor:
        flags: GlobalState.cursor(['stores', 'companies', 'flags', @props.uuid])


  renderTags: ->
    return null if @props.readOnly

    <TagsComponent 
      taggable_id = { @props.uuid }
      taggable_type = 'Company'
      readOnly = { @props.readOnly } />

  render: ->
    return null unless @state.company

    <header>
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
          <label className={ @getNameClass() }>
              <AutoSizingInput
                value = { @state.name }
                onBlur = { @handleFieldBlur.bind(@, 'name') }
                onChange = { @handleFieldChange.bind(@, 'name') }
                onKeyUp = { @handleFieldKeyUp }
                placeholder = 'Company name'
                readOnly = { @props.readOnly }
              />
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

      { @renderTags() }
      
      <div className="buttons">
        { @getFollowButton() }
        <ShareButtons object = @state.company.toJS() />
      </div>

      <InviteActions ownerId = { @props.uuid } ownerType = 'Company' />
    </header>


# Exports
#
module.exports = Component
