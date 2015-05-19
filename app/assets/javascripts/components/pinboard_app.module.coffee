# @cjsx React.DOM

GlobalState     = require('global_state/state')

# Stores
#
PinboardStore   = require('stores/pinboard_store')
UserStore       = require('stores/user_store.cursor')


# Components
#
PinboardSettings = require('components/pinboards/settings')
PinboardPins     = require('components/pinboards/pins/pinboard')
PinboardTabs     = require('components/pinboards/tabs')



# Exports
#
module.exports = React.createClass

  displayName: 'PinboardApp'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      pinboard: ->
        """
          Pinboard {
            user,
            readers,
            followers,
            pins
          }
        """

  propTypes:
    uuid: React.PropTypes.string.isRequired

  getDefaultProps: ->
    cursor:
      pinboards: PinboardStore.cursor.items

  getInitialState: ->
    uuid:       @props.uuid
    currentTab: null

  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.uuid })


  # Helpers
  #
  isLoaded: ->
    @getPinboard()

  getPinboard: ->
    PinboardStore.cursor.items.cursor(@props.uuid).deref(false)

  getOwner: ->
    UserStore.cursor.items.get(@getPinboard().get('user_id'))


  # Handlers
  #
  handleTabChange: (tab) ->
    @setState currentTab: tab


  # Lifecycle methods
  #
  componentWillMount: ->
    @fetch() unless @isLoaded()


  # Renderers
  #
  renderHeader: ->
    <section>
      <header>
        { @getPinboard().get('title') } by { @getOwner().get('full_name') }
      </header>
      <ul className="counter">
        <li>
          { @getPinboard().get('readers_count') }
          <span className="icon">
            <i className="fa fa-male" />
          </span>
        </li>
      </ul>
    </section>

  renderContent: ->
    switch @state.currentTab
      when 'insights'
        <PinboardPins pinboard_id = { @props.uuid } />
      when 'settings'
        <PinboardSettings uuid = { @props.uuid } />
      else
        null


  render: ->
    return null unless @isLoaded()

    <section className="pinboard-wrapper">
      { @renderHeader() }
      <PinboardTabs onChange = { @handleTabChange } />
      { @renderContent() }
    </section>