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
            companies,
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
    count = PinStore.filterByUserId(@cursor.user.get('uuid')).size

    if count > 0
      pluralize(count, 'pin', 'pins')

  getCompaniesCount: ->
    # count = @cursor.companies.filterByUserId(@cursor.user.get('uuid')).size

    # if count > 0
    #   pluralize(count, 'company', 'companies')


  # Handlers
  #


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = 
      user:      UserStore.cursor.items.cursor(@props.uuid)

    @fetch() unless @isLoaded()


  # Renderers
  #
  renderUserStats: ->
    pinsCount = @getPinsCount()
    companiesCount = @getCompaniesCount()

    <p className="stats">
      { @getCompaniesCount() }
      { @getPinsCount() }
    </p>


  render: ->
    return null unless @isLoaded()

    <section className="info">
      <aside>
        <Avatar avatarURL = { @cursor.user.get('avatar_url') } />
      </aside>
      <section className="personal">
        <label className="name">
          <AutoSizingInput 
            value = { @cursor.user.get('full_name') } />
        </label>
        { @renderUserStats() }
      </section>
    </section>
