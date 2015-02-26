# @cjsx React.DOM

# Imports
# 
PinboardStore = require('stores/pinboard_store')

ModalStack = require('components/modal_stack')


# Utils
#
# cx = React.addons.classSet

Roles = 
  editor: 'Editor'
  reader: 'Reader'
  follower: 'Nobody'


# Main component
# 
MainComponent = React.createClass

  displayName: 'PinboardInviteForm'
  # mixins: []
  # propTypes: {}


  # Helpers
  # 
  # gatherSomething: ->


  # Handlers
  # 
  handleBackButtonClick: (event) ->
    ModalStack.hide()

  handleSubmit: (event) ->
    event.preventDefault()

    PinboardStore.sendInvite(@props.pinboard, { email: @state.email, role: @state.role }).then(@handleInviteSave, @handleInviteFail)

  handleEmailChange: (event) ->
    @setState email: event.target.value

  handleInviteSave: (json) ->
    console.log 'handleInviteSave'

  handleInviteFail: ->
    console.warn 'handleInviteFail'

  handleRoleChange: (event) ->
    @setState role: event.target.value


  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


  # Component Specifications
  # 
  # getDefaultProps: ->

  getInitialState: ->
    email: ''
    role: 'editor'
    errors: Immutable.Map({})


  # Renderers
  # 
  # renderSomething: ->


  # Main render
  # 
  render: ->
    <div className="pinboard-invite">
      <header>
        <button className="transparent" onClick={@handleBackButtonClick} disabled={false}>
          <i className="fa fa-angle-left" />
        </button>

        <span>Share <strong>{ @props.pinboard.get('name') }</strong></span>
      </header>

      <form onSubmit={@handleSubmit} >
        <fieldset className="roles">
          <input 
            id="role-editor"
            type="radio"
            value="editor"
            checked={@state.role is 'editor'}
            onChange={@handleRoleChange}
          />
          <label htmlFor="role-editor">{Roles.editor}</label>

          <input 
            id="role-reader"
            type="radio"
            value="reader"
            checked={@state.role is 'reader'}
            onChange={@handleRoleChange}
          />
          <label htmlFor="role-reader">{Roles.reader}</label>

          <input 
            id="role-follower"
            type="radio"
            value="follower"
            checked={@state.role is 'follower'}
            onChange={@handleRoleChange}
          />
          <label htmlFor="role-follower">{Roles.follower}</label>
        </fieldset>

        <footer>
          <input 
            id="email"
            name="email"
            value={@state.email}
            placeholder="user@example.com"
            onChange={@handleEmailChange}
          />

          <button className="cc cc-wide" type="submit" disabled={false}>
            Invite
          </button>

        </footer>

      </form>
    </div>


# Exports
# 
module.exports = MainComponent
