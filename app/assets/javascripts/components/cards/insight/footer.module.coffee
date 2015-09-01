# @cjsx React.DOM

GlobalState          = require('global_state/state')

PinStore             = require('stores/pin_store')
UserStore            = require('stores/user_store.cursor')

ModalStack           = require('components/modal_stack')
PinForm              = require('components/form/pin_form')
InsightStarButton    = require('components/cards/insight/star_button')
InsightSaveButton    = require('components/cards/insight/save_button')
InsightEditButton    = require('components/cards/insight/edit_button')
InsightDropButton    = require('components/cards/insight/drop_button')
InsightOrigin        = require('components/cards/insight/origin')

cx = React.addons.classSet


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

  getInitialState: ->
    ready:      false
    pin:        {}
    save_sync:  false


  statics:
    queries:
      pin: ->

        query = """
          #{InsightOrigin.getQuery('pin')},
          #{InsightStarButton.getQuery('pin')},
          #{InsightDropButton.getQuery('pin')},
          edges {
            is_mine,
            is_editable,
            is_followed
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
  componentWillMount: ->
    @cursor =
      insights: PinStore.cursor.items

  componentDidMount: ->
    @fetch()


  # Renderers
  #
  renderContent: ->
    <section className="content">
      <InsightOrigin pin = { @state.insight.uuid } />
    </section>


  renderEditButton: ->
    return null unless @props.scope == 'standalone'
    <InsightEditButton pin={ @state.insight.id } is_editable={ @state.insight.is_editable } onDone={ @fetchPinboard } />


  # Main render
  #
  render: ->
    return null unless @state.ready

    is_followed = PinStore.get(@state.insight.id).get('is_followed', false)

    <footer>
      <ul className="round-buttons">
        <InsightStarButton pin={ @state.insight.id } />
        <InsightSaveButton pin={ @state.insight.id } is_followed={ is_followed } is_mine={ @state.insight.is_mine } onDone={ @fetchPinboard } />
        { @renderEditButton() }
        <InsightDropButton pin={ (@state.pin || @state.insight).id } onDone={ @fetchPinboard } scope={ @props.scope } />
      </ul>
      { @renderContent() }
    </footer>
