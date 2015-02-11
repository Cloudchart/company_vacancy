# @cjsx React.DOM

GlobalState = require('global_state/state')
cx          = React.addons.classSet


# Stores
#
PinboardStore   = require('stores/pinboard_store')


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
      <span className="title">
        { @cursor.pinboard.get('title') }
      </span>
      <span className="pinboard-access-rights">
        { @renderAccessRightsIcon() }
      </span>
    </header>


  renderDescription: ->
    <section className="description">
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    </section>


  renderFooter: ->
    classList = cx
      'top-line':       true
      'having-owner':   @cursor.pinboard.get('user_id', false)

    <footer className={ classList }>
      <ul>
        <li>
          { 24 }
          <i className="fa fa-user" />
        </li>
        <li>
          { 42 }
          <i className="fa fa-thumb-tack" />
        </li>
      </ul>
    </footer>


  render: ->
    return null unless @isLoaded()

    <section className="pinboard">
      { @renderHeader() }
      { @renderDescription() }
      { @renderFooter() }
    </section>
