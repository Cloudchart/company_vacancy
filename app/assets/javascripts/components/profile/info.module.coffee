# @cjsx React.DOM


GlobalState     = require('global_state/state')

UserStore       = require('stores/user_store.cursor')
CompanyStore    = require('stores/company_store.cursor')
PinStore        = require('stores/pin_store')

pluralize       = require('utils/pluralize')

AutoSizingInput = require('components/form/autosizing_input')
Avatar          = require('components/avatar')

module.exports  = React.createClass

  # Component specifications
  #
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:
      user: ->
        """
          User {
            owned_companies,
            pins,
            roles
          }
        """

  propTypes:
    uuid:     React.PropTypes.string.isRequired
    readOnly: React.PropTypes.bool

  fetch: ->
    GlobalState.fetch(@getQuery('user'), id: @props.uuid)


  # Helpers
  #
  isLoaded: ->
    @cursor.user.deref(false)

  getPinsCount: ->
    count = PinStore.filterByUserId(@props.uuid).size

    if count > 0
      pluralize(count, 'pin', 'pins')

  getCompaniesCount: ->
    count = CompanyStore.filterForUser(@props.uuid).size

    if count > 0
      pluralize(count, 'company', 'companies')


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = 
      user:  UserStore.cursor.items.cursor(@props.uuid)

    @fetch() unless @isLoaded()


  # Renderers
  #
  renderUserStats: ->
    counters = []

    if companiesCount = @getCompaniesCount() then counters.push(companiesCount)
    if pinsCount = @getPinsCount() then counters.push(pinsCount)

    <p className="stats">{ counters.join(', ') }</p>


  render: ->
    return null unless @isLoaded()

    <section className="info">
      <aside>
        <Avatar 
          avatarURL = { @cursor.user.get('avatar_url') }
          value     = { @cursor.user.get('full_name') } />
      </aside>
      <section className="personal">
        <h1> { @cursor.user.get('full_name') } </h1>
        { @renderUserStats() }
      </section>
    </section>
