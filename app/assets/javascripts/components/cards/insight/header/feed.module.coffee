# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')
UserStore = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')

# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'InsightCardHeaderFeed'
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    pin: React.PropTypes.string.isRequired

  statics:
    queries:
      pin: ->
        """
          Pin {
            pinboard,
            user {
              edges {
                is_followed
              }
            }
          }
        """


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin }).then =>
      pin = PinStore.get(@props.pin).toJS()

      @setState
        ready: true
        pin: pin
        user: UserStore.get(pin.user_id).toJS()
        pinboard: PinboardStore.get(pin.pinboard_id).toJS() if pin.pinboard_id


  # Component Specifications
  #
  # getDefaultProps: ->

  getInitialState: ->
    ready: false
    pin: {}
    user: {}
    pinboard: {}


  # Lifecycle Methods
  #
  # componentWillMount: ->

  componentDidMount: ->
    @fetch()

  # componentWillUnmount: ->


  # Helpers
  #
  # getSomething: ->


  # Handlers
  #
  # handleThingClick: (event) ->


  # Renderers
  #
  renderIcon: (iconClass) ->
    <i key='icon' className="fa fa-#{iconClass}" />

  renderUser: ->
    <a key='user' className='user' href={ @state.user.url }>{ @state.user.full_name }</a>

  renderComment: (comment) ->
    <span key='comment' className='comment'>{ comment }</span>

  renderPinboard: ->
    return null unless @state.pinboard
    <a href={ @state.pinboard.url } key='pinboard' className='pinboard see-through'>{ @state.pinboard.title }</a>

  renderContent: ->
    if @state.pin.is_suggestion
      [
        @renderUser()
        @renderComment('suggested insight to')
        @renderPinboard()
      ]
    else if @state.pin.kind == 'reflection'
      [
        @renderIcon(if @state.pin.is_approved then 'thumbs-o-up' else 'thumbs-o-down')
        @renderUser()
        @renderComment(if @state.pin.content then "added reflection – #{@state.pin.content}" else 'added reflection')
      ]
    else if @state.pin.parent_id && @state.pin.content
      [
        @renderIcon('comment-o')
        @renderUser()
        @renderComment("— #{@state.pin.content}")
        @renderPinboard()
      ]
    else if @state.user.is_followed
      [
        @renderUser()
        @renderComment('added insight to')
        @renderPinboard()
      ]
    else
      @renderPinboard()


  # Main render
  #
  render: ->
    return null unless @state.ready

    <header>
      <section className="title">
        { @renderContent() }
      </section>
    </header>
