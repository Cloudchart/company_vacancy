# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinStore    = require('stores/pin_store')
UserStore   = require('stores/user_store.cursor')


# Components
#
Human             = require('components/human')
PinButton         = require('components/pinnable/pin_button')
EditPinButton     = require('components/pinnable/edit_pin_button')
ApprovePinButton  = require('components/pinnable/approve_pin_button')
Tooltip           = require('components/shared/tooltip')
StandardButton    = require('components/form/buttons').StandardButton

trimDots          = require('utils/trim_string').trimDots


# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'InsightItem'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    getCursor: (id) ->
      pin:    PinStore.cursor.items.cursor(id)
      users:  UserStore.cursor.items

    queries:
      system_roles: ->
        """
          Viewer {
            system_roles
          }
        """

  gatherAttributes: ->
    uuid:           @getInsight().get('uuid')
    parent_id:      @getInsight().get('parent_id')
    pinnable_id:    @props.cursor.pin.get('pinnable_id')
    pinnable_type:  @props.cursor.pin.get('pinnable_type')

  getStateFromStores: ->
    user: @props.cursor.users.cursor(@getInsight().get('user_id'))

  onGlobalStateChange: ->
    @setState @getStateFromStores()

  getInitialState: ->
    @getStateFromStores()

  isSuggested: ->
    @props.cursor.pin.get('is_suggestion')

  getInsight: ->
    if @isSuggested()
      PinStore.getParentFor(@props.cursor.pin.get('uuid'))
    else
      @props.cursor.pin

  destroySuggestion: ->
    PinStore.destroy(@props.cursor.pin.get('uuid')) if confirm('Are you sure?')

  getOrigin: ->
    @getInsight().get('origin')

  getContent: ->
    content = @getInsight().get('content')

    if @getOrigin() then trimDots(content) else content


  # Helpers
  #
  isLink: (string) ->
    /^https?:\/\/.*/.test(string)


  # Lifecycle methods
  #
  componentWillMount: ->
    GlobalState.fetch(@getQuery('system_roles'))


  # Renderers
  #
  renderOriginIcon: ->
    <i className="fa fa-code" />

  renderOrigin: ->
    return null unless (origin = @getOrigin())

    if @isLink(origin)
      <a className="origin" href={ origin } target="_blank">
        { @renderOriginIcon() }
      </a>
    else
      <Tooltip 
        className      = "origin"
        element        = { @renderOriginIcon() }
        tooltipContent = { origin } />
      
  renderContent: ->
    <section className="content">
      { @getContent() }
      { " " }
      { @renderOrigin() }
    </section>

  renderApproveButton: ->
    return null if @isSuggested()

    <ApprovePinButton uuid = { @props.uuid } />

  renderEditButton: ->
    return null if @isSuggested()

    <EditPinButton uuid={ @props.uuid } />

  renderButtons: ->
    <ul className="round-buttons">
      { @renderApproveButton() }
      { @renderEditButton() }
      <PinButton {...@gatherAttributes()} title={ @getInsight().get('content') } />
    </ul>

  renderSuggestionDeleteButton: ->
    return null unless UserStore.isEditor()

    <StandardButton 
      className = "transparent"
      iconClass = "cc-icon cc-times"
      onClick   = { @destroySuggestion } />

  renderSuggestion: ->
    return null unless @isSuggested()

    <section className="suggestion">
      <i className="svg-icon svg-cloudchart-logo" />
      Suggested by CloudChart
      { @renderSuggestionDeleteButton() }
    </section>


  render: ->
    return null unless @props.cursor.pin.deref(false)
    return null unless @state.user.deref(false)

    insightClasses = cx
      insight:    true
      item:       true
      unapproved: !@getInsight().get('is_approved')
      suggested:  @isSuggested()

    <article className = { insightClasses } >
      <Human 
        uuid            = { @getInsight().get('user_id') }
        showUnicornIcon = { true }
        type            = "user" />
      { @renderContent() }
      { @renderButtons() }
      { @renderSuggestion() }
    </article>
