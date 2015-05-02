# @cjsx React.DOM

GlobalState      = require('global_state/state')

PinStore         = require('stores/pin_store')
UserStore        = require('stores/user_store.cursor')

PinForm          = require('components/form/pin_form')
Modal            = require('components/modal_stack')
StandardButton   = require('components/form/buttons').StandardButton

PinsList         = require('components/pinboards/pins')
PinComponent     = require('components/pinboards/pin')


# Utils
#
cx = React.addons.classSet


# Main component
# 
MainComponent = React.createClass

  displayName: 'LimboApp'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      insights: ->
        """
          Viewer {
            limbo_pins {
              #{PinComponent.getQuery('pin')}
            }
          }
        """

  PropTypes:
    showCreateButton: React.PropTypes.bool
    showSearch:       React.PropTypes.bool
    onItemClick:      React.PropTypes.func

  getDefaultProps: ->
    cursor: 
      pins: PinStore.cursor.items
    showCreateButton: false
    showSearch:       false

  getInitialState: ->
    isLoaded: false
    query:    ''


  # Helpers
  # 
  isLoaded: ->
    @state.isLoaded

  fetch: ->
    GlobalState.fetch(@getQuery('insights'))

  gatherInsights: ->
    @props.cursor.pins
      .filter (pin) =>
        !pin.get('parent_id') && !pin.get('pinnable_id') && 
        pin.get('author_id') && pin.get('content')
      .filter (pin) =>
        !@state.query ||
        (pin.get('content').indexOf(@state.query) != -1 ||
         @cursor.users.get(pin.get('user_id')).get('full_name').indexOf(@state.query)) != -1
      .valueSeq()
      .sortBy (pin) -> pin.get('created_at')
      .reverse()
      .toArray()


  # Handlers
  # 
  handleCreateButtonClick: ->
    Modal.show(@renderPinForm())

  handleQueryChange: (event) ->
    @setState query: event.target.value


  # Lifecycle Methods
  # 
  componentWillMount: ->
    @cursor = 
      users: UserStore.cursor.items

    @fetch().then => @setState isLoaded: true


  # Renderers
  # 
  renderPinForm: ->
    <PinForm
      onDone        = { Modal.hide }
      onCancel      = { Modal.hide } />

  renderSearch: ->
    return null unless @props.showSearch

    <header>
      <input
        autoFocus   =  { true }
        value       =  { @state.query }
        onChange    =  { @handleQueryChange }
        placeholder = 'Search by content or author' />
    </header>

  renderCreateButton: ->
    return null unless @props.showCreateButton

    <StandardButton
      className = "cc"
      text      = "Create Insight"
      onClick   = { @handleCreateButtonClick } />


  # Main render
  # 
  render: ->
    return null unless @isLoaded()

    <section className="limbo">
      { @renderSearch() }
      { @renderCreateButton() }
      <PinsList
        onItemClick   = { @props.onItemClick }
        pins          = { @gatherInsights() }
        showPinButton = { false } />
    </section>


# Exports
# 
module.exports = MainComponent
