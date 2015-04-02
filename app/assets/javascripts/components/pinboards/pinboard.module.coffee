# @cjsx React.DOM

GlobalState = require('global_state/state')
cx          = React.addons.classSet


# Stores
#
PinboardStore   = require('stores/pinboard_store')
UserStore       = require('stores/user_store.cursor')


# Components
#
Human = require('components/human')


# Exports
#
module.exports = React.createClass


  displayName: 'PinboardPreview'


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


  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.uuid }).then =>
      @setState
        loaders: @state.loaders.set('pinboard', true)


  isLoaded: ->
    @cursor.pinboard.deref(false)


  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.uuid)

    @fetch() unless @isLoaded()


  getInitialState: ->
    loaders: Immutable.Map()


  renderAccessRightsIcon: ->
    classList = cx
      'fa':       true
      'fa-lock':  @cursor.pinboard.get('access_rights') is 'private'
      'fa-users': @cursor.pinboard.get('access_rights') is 'protected'

    <i className={ classList } />


  renderHeader: ->
    <header>
      { @cursor.pinboard.get('title') }
      { @renderAccessRightsIcon() }
    </header>


  renderDescription: ->
    return unless description = @cursor.pinboard.get('description', false)

    <section className="paragraph">
      { description }
    </section>


  renderFooter: ->
    <footer>
      <Human type="user" uuid={ @cursor.pinboard.get('user_id') } />

      <ul className="counters">
        <li>
          { @cursor.pinboard.get('readers_count') }
          <i className="fa fa-user" />
        </li>
        <li>
          { @cursor.pinboard.get('pins_count') }
          <i className="fa fa-thumb-tack" />
        </li>
      </ul>
    </footer>


  render: ->
    return null unless @isLoaded()

    <section className="pinboard cloud-card link">
      <a className="for-group" href={ @cursor.pinboard.get('url') }>
        { @renderHeader() }
        { @renderDescription() }
        { @renderFooter() }
      </a>
    </section>
