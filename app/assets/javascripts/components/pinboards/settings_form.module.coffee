# @cjsx React.DOM


# Stores
#
PinboardStore = require('stores/pinboard_store')


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
    
    PinboardStore.update(@props.cursor.get('uuid'), @state.attributes.toJSON()).then(@handleUpdateDone, @handleUpdateFail)
  
  
  handleUpdateDone: (json) ->
    @props.onCancel()
  
  
  handleUpdateFail: (xhr) ->
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
      access_rights: @props.cursor.get('access_rights', 'public')
  
  
  renderAccessRights: ->
    handleChange = @handleChange.bind(@, 'access_rights')

    AccessRights.map (name, value) =>
      <label key={ value }>
        <input
          name      = "access_rights"
          type      = "radio"
          value     = { value }
          checked   = { @state.attributes.get('access_rights') == value }
          onChange  = { handleChange }
        />
        { name }
      </label>
  
  
  renderInputs: ->
    <dl>
      <dt>
        Access Rights
      </dt>
      <dd>
        { @renderAccessRights().toArray() }
      </dd>
    </dl>
  
  
  renderFormButtons: ->
    <footer>
      <button type="button" onClick={ @props.onCancel }>
        Cancel
      </button>
      <button type="submit">
        Update
      </button>
    </footer>


  render: ->
    <form className="pinboard-settings" onSubmit={ @handleFormSubmit }>
      { @renderInputs() }
      { @renderFormButtons() }
    </form>
