# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')

Reflection  = require('components/cards/insight/header/reflection')
Pinboard    = require('components/cards/insight/header/pinboard')
Feed        = require('components/cards/insight/header/feed')


# Utils
#
# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'InsightCardHeader'

  propTypes:
    pin: React.PropTypes.string.isRequired
    scope: React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      pin: ->
        """
          Pin {
            #{Pinboard.getQuery('pin')},
            #{Feed.getQuery('pin')},
            parent {
              edges {
                should_show_reflection
              }
            },
            edges {
              should_show_reflection
            }
          }
        """


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pin', @props), { id: @props.pin }).then =>
      pin = PinStore.get(@props.pin).toJS()
      @addCursor('insight', PinStore.cursor.items.cursor(pin.parent_id || pin.id))

      @setState
        ready: true
        pin: PinStore.get(@props.pin).toJS()


  # Component Specifications
  #
  getDefaultProps: ->
    scope: 'pinboard'

  getInitialState: ->
    ready: false
    pin: {}


  # Lifecycle Methods
  #
  componentDidMount: ->
    @fetch()


  # Main render
  #
  render: ->
    return null unless @state.ready

    if @getCursor('insight').get('should_show_reflection', false)
      <Reflection insight={ @getCursor('insight').get('id') } />
    else
      switch @props.scope
        when 'pinboard' then <Pinboard pin = { @state.pin.id } />
        when 'feed' then <Feed pin = { @state.pin.id } />
        else null
