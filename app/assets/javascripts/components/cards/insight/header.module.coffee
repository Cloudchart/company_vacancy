# @cjsx React.DOM

GlobalState     = require('global_state/state')

PinStore        = require('stores/pin_store')
UserStore       = require('stores/user_store.cursor')
PinboardStore   = require('stores/pinboard_store')


# Utils
#
# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'InsightCardHeader'

  propTypes:
    pin: React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

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


  # Component Specifications
  #

  getInitialState: ->
    ready:      false
    pin:        {}
    user:       {}
    pinboard:   {}


  # Lifecycle Methods
  #

  componentDidMount: ->
    @fetch()


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin }).then =>
      pin = PinStore.get(@props.pin).toJS()

      @setState
        ready:    true
        pin:      pin
        user:     UserStore.get(pin.user_id).toJS()
        pinboard: PinboardStore.get(pin.pinboard_id).toJS() if pin.pinboard_id


  renderIcon: ->
    <i key='icon' className='fa fa-comment-o' />


  renderContentWithUserCommentAndPinboard: (comment, options = {}) ->
    [
      @renderIcon() if options.icon
      <section className="title">
        <a key='user' className='user' href={ @state.user.url }>{ @state.user.full_name }</a>
        <span key='comment' className='comment'>{ comment }</span>
        { @renderContentWithPinboard() }
      </section>
    ]

  renderContentWithPinboard: ->
    return null unless @state.pinboard
    <a href={ @state.pinboard.url } key='pinboard' className='pinboard see-through'>{ @state.pinboard.title }</a>


  # Render content
  #   Cases:
  #     1. User suggested insight [%User% suggested insight to %Pinboard%]
  #     2. User pinned insight without comment
  #     2.1 User is followed [%User% added insight to %Pinboard%]
  #     2.2 User is not followed [%Pinboard%]
  #     3. User pinned insight with comment [%User% %Comment% in %Pinboard%]
  #     4. User created insight [%User% added insight to %Pinboard%]
  #
  renderContent: ->
    if @state.pin.parent_id
      if @state.pin.is_suggestion
        @renderContentWithUserCommentAndPinboard('suggested insight to')
      else if @state.pin.content
        @renderContentWithUserCommentAndPinboard('— ' + @state.pin.content + ' in', icon: true)
      else if @state.user.is_followed
        @renderContentWithUserCommentAndPinboard('added insight to')
      else
        @renderContentWithPinboard()
    else
      @renderContentWithUserCommentAndPinboard('added insight to')



  # Main render
  #
  render: ->
    <header>{ @renderContent() }</header>
