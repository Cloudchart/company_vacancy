# @cjsx React.DOM

GlobalState         = require('global_state/state')

# Imports
#
ModalStack          = require('components/modal_stack')
CloseModalButton    = require('components/form/buttons').CloseModalButton
SuggestedPinboards  = require('components/suggestions/pinboards')
SuggestedInsights   = require('components/suggestions/insights')

PinStore            = require('stores/pin_store')

# Utils
#
cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'SuggestionApp'

  propTypes:
    uuid: React.PropTypes.string.isRequired
    type: React.PropTypes.string.isRequired


  mixins: [GlobalState.query.mixin]


  statics:
    queries:
      pinboard: ->
        """
          Pinboard {
            edges {
              pins_ids
            }
          }
        """


  getInitialState: ->
    ready:                false
    query:                ''
    current_pinboard_id:  null


  # Events
  #

  handlePinboardSelect: (pinboard_id) ->
    @setState
      current_pinboard_id: pinboard_id


  handlePinSelect: (id) ->
    insight = PinStore.get(id).toJS()

    attributes =
      parent_id:      insight.id
      pinboard_id:    if @props.type is 'Pinboard'  then @props.uuid else null
      pinnable_id:    if @props.type is 'Post'      then @props.uuid else insight.pinnable_id
      pinnable_type:  if @props.type is 'Post'      then @props.type else insight.pinnable_type
      is_suggestion:  true

    PinStore.create(attributes).then(ModalStack.hide, ModalStack.hide).then =>
      GlobalState.fetch(@getQuery('pinboard'), { id: @props.uuid, force: true }) if @props.type == 'Pinboard'



  handleBack: ->
    @setState
      current_pinboard_id: null


  # Renderers
  #

  renderBackButton: ->
    return null unless @state.current_pinboard_id

    <button key="back-button" className="back transparent" onClick={ @handleBack }>
      <i className="fa fa-angle-left" />
    </button>


  renderContent: ->
    if @state.current_pinboard_id
      <SuggestedInsights pinboard={ @state.current_pinboard_id } onSelect={ @handlePinSelect } />
    else
      <SuggestedPinboards onSelect={ @handlePinboardSelect } />


  # Main render
  #
  render: ->
    <section className="suggestions">
      { @renderContent() }
      { @renderBackButton() }
      <CloseModalButton />
    </section>
