# @cjsx React.DOM

GlobalState         = require('global_state/state')

PinStore            = require('stores/pin_store')
UserStore           = require('stores/user_store.cursor')

ModalStack          = require('components/modal_stack')
PinForm             = require('components/form/pin_form')
InsightStarButton   = require('components/cards/insight/star_button')
InsightSaveButton   = require('components/cards/insight/save_button')
InsightDropButton   = require('components/cards/insight/drop_button')


cx = React.addons.classSet

DOMAIN_RE = /^http[s]{0,1}\:\/\/([^\/]+)/i


# Main component
#
module.exports = React.createClass

  displayName: 'InsightCardFooter'

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


  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      pin: ->

        query = """
          #{InsightStarButton.getQuery('pin')},
          #{InsightDropButton.getQuery('pin')},
          edges {
            is_origin_domain_allowed,
            is_mine
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
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin }).then =>
      pin       = PinStore.get(@props.pin).toJS()
      insight   = PinStore.get(pin.parent_id).toJS() if pin.parent_id

      @setState
        ready:    true
        pin:      pin if insight
        insight:  insight || pin



  # Helpers
  #

  getSaveButtonActiveState: ->
    @state.insight.is_mine


  renderPinForm: ->
    pin = @state.insight || @state.pin
    pin =
      parent_id:      pin.uuid
      pinnable_id:    pin.pinnable_id
      pinnable_type:  pin.pinnable_type
      title:          pin.content

    <PinForm {...pin} onDone={ ModalStack.hide } onCancel={ ModalStack.hide } />


  # Handlers
  #

  handleSaveButtonClick: ->
    return false
    ModalStack.show(@renderPinForm())


  # Lifecycle
  #

  componentDidMount: ->
    @fetch()


  # Renderers
  #

  renderOrigin: ->
    return null unless @state.insight.origin && @state.insight.is_origin_domain_allowed
    return null unless (parts = DOMAIN_RE.exec(@state.insight.origin)) and parts.length == 2
    <a href={ @state.insight.origin } target="_blank">{ parts[1] }</a>


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
        <InsightSaveButton active={ @getSaveButtonActiveState() } sync={ @state.save_sync } onClick={ @handleSaveButtonClick } />
        <InsightDropButton pin={ (@state.pin || @state.insight).id } scope={ @props.scope } />
        <InsightStarButton pin={ @state.insight.id } />
      </ul>
      { @renderContent() }
    </footer>
