# @cjsx React.DOM

UserStore = require('stores/user_store.cursor')

# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'InsightCardHeaderPinboard'
  # mixins: []

  propTypes:
    pin: React.PropTypes.object.isRequired

  # statics: {}


  # Fetchers
  #
  # fetch: ->


  # Component Specifications
  #
  # getDefaultProps: ->
  # getInitialState: ->


  # Lifecycle Methods
  #
  componentWillMount: ->
    @cursor =
      user: UserStore.get(@props.pin.user_id).toJS()

  # componentDidMount: ->
  # componentWillUnmount: ->


  # Helpers
  #
  getComment: ->
    if @state.pinboard.is_editable
      if @state.pin.is_suggestion
        @renderUserComment('suggested insight')
      else if @state.pin.content
        @renderUserComment('— ' + @state.pin.content)
      else
        @renderUserComment('added insight')
    else
      @renderUserComment('— ' + @state.pin.content) if @state.pin.content unless @state.pin.is_suggestion


  # Handlers
  #
  # handleThingClick: (event) ->


  # Renderers
  #
  # renderSomething: ->


  # Main render
  #
  render: ->
    return null unless @props.pin.parent_id

    <header>
      <section key="title" className="title">
        <a className='user' href={ @cursor.user.url }>{ @cursor.user.full_name }</a>
        <span className='comment'>{ @getComment() }</span>
      </section>
    </header>
