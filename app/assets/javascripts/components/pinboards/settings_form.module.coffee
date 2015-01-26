# @cjsx React.DOM


# Stores
#
PinboardStore = require('stores/pinboard_store')


# Components
#
FormControlComponent = React.createClass

  render: ->
    <section className="form-section">
      <span className="title">{ @props.title }</span>
      <div className="form-control-wrapper">
        { @props.children }
      </div>
    </section>


# Constants
#
AccessRights = Immutable.Seq
  'public':     'Public'
  'protected':  'Protected'
  'private':    'Private'


# Exports
#
module.exports = React.createClass


  handleFormSubmit: (event) ->
    event.preventDefault()
    
    return if @props.cursor.get('--sync--') == true
    
    if uuid = @props.cursor.get('uuid')
      PinboardStore.update(uuid, @state.attributes.toJSON()).then(@handleSaveDone, @handleSaveFail)
    else
      PinboardStore.create(@state.attributes.toJSON()).then(@handleSaveDone, @handleSaveFail)
  
  
  handleSaveDone: (json) ->
    @props.onCancel()
  
  
  handleSaveFail: (xhr) ->
    snabbt(@getDOMNode().parentNode, 'attention', {
      position: [50, 0, 0]
      springConstant: 3
      springDeacceleration: .9
    })
  
  
  handleKeyDown: (event) ->
    if event.keyCode == 27
      @props.onCancel()
  
  
  handleChange: (name, event) ->
    @setState
      attributes: @state.attributes.set(name, event.target.value)
  
  
  componentDidMount: ->
    window.addEventListener('keydown', @handleKeyDown)
  
  
  componentWillUnmount: ->
    window.removeEventListener('keydown', @handleKeyDown)
  
  
  getDefaultProps: ->
    onCancel:     ->
    defaultAccessRights: 'public'
  
  
  getInitialState: ->
    attributes: Immutable.Map
      title:          @props.cursor.get('title', '')
      access_rights:  @props.cursor.get('access_rights', 'public')
  
  
  renderHeader: ->
    <header className="form-header">
      Pinboard
      <div className="title">{ @props.cursor.get('title') }</div>
    </header>
  
  
  renderTitle: ->
    <FormControlComponent title="Name">
      <input
        className   = "form-control"
        autoFocus   = { !@props.cursor.get('uuid') }
        type        = "text"
        placeholder = "Pick a name"
        value       = { @state.attributes.get('title') }
        onChange    = { @handleChange.bind(@, 'title') }
      />
    </FormControlComponent>
  
  
  renderAccessRightsOptions: ->
    AccessRights
      .map (name, value) ->
        <option key={ value } value={ value }>{ name }</option>
  
  
  renderAccessRightsSelect: ->
    <FormControlComponent title="Access Rights">
      <select
        className = "form-control"
        value     = { @state.attributes.get('access_rights') }
        onChange  = { @handleChange.bind(@, 'access_rights') }
      >
        { @renderAccessRightsOptions().toArray() }
      </select>
      <i className="fa fa-angle-down control" />
    </FormControlComponent>
  
  
  renderInputs: ->
    
    <fieldset className="form-fieldset">
      { @renderTitle() }
      { @renderAccessRightsSelect() }
    </fieldset>
    

  renderFormButtons: ->
    <footer className="form-footer">
      <button type="button" className="cc cancel" onClick={ @props.onCancel }>
        Cancel
      </button>
      <button type="submit" className="cc">
        { if @props.cursor.get('uuid') then 'Update' else 'Create' }
      </button>
    </footer>


  render: ->
    <form className="pinboard-settings" onSubmit={ @handleFormSubmit }>
      { @renderHeader() }
      { @renderInputs() }
      { @renderFormButtons() }
    </form>
