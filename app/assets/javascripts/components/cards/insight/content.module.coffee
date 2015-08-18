# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')
UserStore = require('stores/user_store.cursor')


# Main component
#
module.exports = React.createClass

  displayName: "InsightContent"

  propTypes:
    pin:      React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      pin: ->
        """
          Pin {
            user,
            edges {
              url
            }
          }
        """


  # Component Specifications
  #
  getDefaultProps: ->
    onUpdate: ->


  getInitialState: ->
    pin:    {}
    user:   {}
    ready:  false


  # Lifecycle Methods
  #
  # componentWillMount: ->

  componentDidMount: ->
    @fetch()


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin }).then =>
      pin   = PinStore.get(@props.pin).toJS()
      user  = UserStore.get(pin.user_id).toJS()
      @setState
        ready:  true
        pin:    pin
        user:   user


  # Helpers
  #
  getContent: ->
    if @state.pin.parent_id
      PinStore.get(@state.pin.parent_id).get('content')
    else
      @state.pin.content


  # Renderers
  #
  renderContent: ->
    <a href={ @state.pin.url } className="content see-through">
      { @getContent() }
    </a>

  renderUser: ->
    <a href={ @state.user.url }>
      { @state.user.full_name }
    </a>


  # Main Render
  #
  render: ->
    return null unless @state.ready

    <section className="content" onClick={ @props.onClick }>
      { @renderContent() }
      <span> &mdash; </span>
      { @renderUser() }
    </section>
