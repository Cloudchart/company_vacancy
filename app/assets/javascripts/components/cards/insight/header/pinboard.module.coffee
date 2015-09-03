# @cjsx React.DOM

GlobalState = require('global_state/state')

UserStore = require('stores/user_store.cursor')
PinStore = require('stores/pin_store')
PinboardStore = require('stores/pinboard_store')

# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'InsightCardHeaderPinboard'
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    pin: React.PropTypes.string.isRequired

  statics:
    queries:
      pin: ->
        """
          Pin {
            pinboard {
              edges {
                is_editable
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
        pinboard: PinboardStore.get(pin.pinboard_id).toJS()


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
  getComment: ->
    if @state.pin.is_suggestion then 'suggested insight'
    else if @state.pin.content then "— #{@state.pin.content}"
    else 'added insight'


  # Handlers
  #
  # handleThingClick: (event) ->


  # Renderers
  #
  # renderSomething: ->


  # Main render
  #
  render: ->
    return null unless @state.ready && @state.pinboard.is_editable && @state.pin.parent_id

    <header>
      <section key="title" className="title">
        <a className='user' href={ @state.user.url }>{ @state.user.full_name }</a>
        <span className='comment'>{ @getComment() }</span>
      </section>
    </header>
