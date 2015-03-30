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
            roles,
            pins,
            published_companies
          }
        """

  propTypes:
    uuid:     React.PropTypes.string.isRequired


  # Helpers
  #
  isLoaded: ->
    @cursor.user.deref(false)

  getPinsCount: ->
    count = PinStore
      .filterByUserId(@props.uuid)
      .filter (pin) -> pin.get('pinnable_id')
      .size

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
      user:       UserStore.cursor.items.cursor(@props.uuid)


  # Renderers
  #
  renderOccupation: ->
    strings = []
    strings.push occupation if (occupation = @cursor.user.get('occupation'))
    strings.push company if (company = @cursor.user.get('company'))

    <div className="occupation">
      { strings.join(', ') }
    </div>

  renderStats: ->
    counters = []

    if companiesCount = @getCompaniesCount() then counters.push(companiesCount)
    if pinsCount = @getPinsCount() then counters.push(pinsCount)

    <div className="stats">{ counters.join(', ') }</div>

  renderTwitter: ->
    twitterHandle = @cursor.user.get('twitter')

    <a className="twitter" href={ "https://twitter.com/" + twitterHandle } target="_blank">@{ twitterHandle }</a>


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
        { @renderOccupation() }
        <div className="spacer"></div>
        { @renderStats() }
        { @renderTwitter() }
      </section>
    </section>
