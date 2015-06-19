# @cjsx React.DOM

# Imports
# 
Human = require('components/human')
CloseModalButton = require('components/form/buttons').CloseModalButton


# Utils
#
# cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  displayName: 'PinboardRealtedUsers'
  # mixins: []
  # statics: {}
  propTypes:
    pinboard: React.PropTypes.object.isRequired
    owner: React.PropTypes.object.isRequired
    users: React.PropTypes.object.isRequired


  # Component Specifications
  # 
  # getDefaultProps: ->
  # getInitialState: ->

  
  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


  # Helpers
  # 
  # getSomething: ->


  # Handlers
  # 
  # handleThingClick: (event) ->


  # Renderers
  # 
  renderUsers: ->
    users = @props.users.map (user, index) ->
      <li key={index}>
        { <Human type="user" uuid = { user.uuid } /> }
      </li>

    <ul>
      { users }
    </ul>


  # Main render
  # 
  render: ->
    <article className="pinboard-related-users">
      { <CloseModalButton /> }

      <header>
        <h1>
          { @props.pinboard.title }
          <strong> – </strong>
          <span className="description">{ @props.pinboard.description }</span>
        </h1>
      </header>

      <section className="content">
        <section className="owner">
          <h1>Collection owner</h1>
          <Human type = "user" uuid = { @props.owner.uuid } />
        </section>

        <section className="users">
          <h1>Contributors</h1>
          { @renderUsers() }
        </section>
      </section>

    </article>
