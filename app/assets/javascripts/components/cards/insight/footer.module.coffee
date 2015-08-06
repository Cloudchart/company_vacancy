# @cjsx React.DOM

GlobalState          = require('global_state/state')

PinStore             = require('stores/pin_store')
UserStore            = require('stores/user_store.cursor')

ModalStack           = require('components/modal_stack')
PinForm              = require('components/form/pin_form')
InsightStarButton    = require('components/cards/insight/star_button')
InsightSaveButton    = require('components/cards/insight/save_button')
InsightDropButton    = require('components/cards/insight/drop_button')


cx = React.addons.classSet
DOMAIN_RE = /^http[s]{0,1}\:\/\/([^\/]+)/i


# Main component
#
module.exports = React.createClass

  displayName: 'InsightCardFooter'
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    pin:    React.PropTypes.string.isRequired
    scope:  React.PropTypes.string.isRequired


  # Specification
  #
  getDefaultProps: ->
    cursor:
      viewer: UserStore.me()

  getInitialState: ->
    ready:      false
    pin:        {}
    save_sync:  false


  statics:
    queries:
      pin: ->

        query = """
          #{InsightStarButton.getQuery('pin')},
          #{InsightDropButton.getQuery('pin')},
          edges {
            is_origin_domain_allowed,
            is_mine,
            diffbot_response_data
          }
        """

        """
          Pin {
            #{query},
            parent {
              #{query}
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin }).then (json) =>
      pin       = PinStore.get(@props.pin).toJS()
      insight   = PinStore.get(pin.parent_id).toJS() if pin.parent_id

      @setState
        ready:    true
        pin:      pin if insight
        insight:  insight || pin


  fetchPinboard: ->
    pinboard_id = (@state.pin || @state.insight).pinboard_id
    return unless pinboard_id
    GlobalState.fetchEdges('Pinboard', pinboard_id)


  # Helpers
  #


  # Handlers
  #


  # Lifecycle
  #
  componentDidMount: ->
    @fetch()


  # Renderers
  #
  renderTitle: ->
    return null unless @state.insight.diffbot_response_data
    return null unless title = @state.insight.diffbot_response_data.title

    <span className="title">{ title + ', ' }</span>


  renderEstimation: ->
    return null unless @state.insight.diffbot_response_data
    return null unless estimated_time = @state.insight.diffbot_response_data.estimated_time

    <span className="estimation">
      <span> &mdash; </span>
      <i className="fa fa-clock-o" />
      { moment.duration(estimated_time, 'seconds').humanize(); }
    </span>


  renderOrigin: ->
    return null unless @state.insight.origin && @state.insight.is_origin_domain_allowed
    return null unless (parts = DOMAIN_RE.exec(@state.insight.origin)) and parts.length == 2
    [_, domain] = parts

    <div className="origin">
      { @renderTitle() }
      <a href={ @state.insight.origin } target="_blank">{ domain }</a>
      { @renderEstimation() }
    </div>


  renderContent: ->
    <section className="content">
      { @renderOrigin() }
    </section>


  # Main render
  #
  render: ->
    return null unless @state.ready

    <footer>
      <ul className="round-buttons">
        <InsightStarButton pin={ @state.insight.id } />
        <InsightSaveButton pin={ @state.insight.id } onDone={ @fetchPinboard } />
        <InsightDropButton pin={ (@state.pin || @state.insight).id } onDone={ @fetchPinboard } scope={ @props.scope } />
      </ul>
      { @renderContent() }
    </footer>
