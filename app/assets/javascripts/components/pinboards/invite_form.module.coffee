# @cjsx React.DOM

# Imports
# 
# SomeComponent = require('')


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
    console.log 'handleBackButtonClick'


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
  # getInitialState: ->


  # Renderers
  # 
  # renderSomething: ->


  # Main render
  # 
  render: ->
    <div className="pinboard-invite-form">
      <header>
        <button className="transparent" onClick={@handleBackButtonClick}>
          <i className="fa fa-angle-left"/>
        </button>

        <span>
          Pinboard Invite Form
        </span>
      </header>

      <div className="content">
        <ul className="roles">
          <li>{Roles.editor}</li>
          <li>{Roles.reader}</li>
          <li>{Roles.follower}</li>
        </ul>
      </div>
    </div>


# Exports
# 
module.exports = MainComponent
