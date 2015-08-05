# @cjsx React.DOM

GlobalState = require('global_state/state')


# Stores
#
PinStore = require('stores/pin_store')
UserStore = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')


# Components
#
Insight = require('components/cards/insight/content')


# Exports
#
module.exports = React.createClass

  displayName: 'SendInsightForm'

  mixins: [GlobalState.query.mixin]

  propTypes:
    pin:        React.PropTypes.string.isRequired
    onDone:     React.PropTypes.func.isRequired
    onCancel:   React.PropTypes.func.isRequired


  statics:
    queries:
      pin: ->
        """
          Pin {
            #{Insight.getQuery('pin')}
          }
        """

      viewer: ->
        """
          Viewer {
            pinboards {
              user
            },
            pinboards_through_roles {
              user
            },
            edges {
              pinboards,
              pinboards_through_roles
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('pin'), ( id: @props.pin ))
    GlobalState.fetch(@getQuery('viewer')).then @populatePinboards


  getInitialState: ->
    ready:      false
    pinboards:  null
    attributes: Immutable.Map({ content: '', pinboard_id: 'new', pinboard_title: '' })


  # Populate Pinboards
  #

  populatePinboard: (pinboard) ->
    pinboard        = PinboardStore.get(pinboard.get('id')).toJS()
    pinboard.user   = UserStore.get(pinboard.user_id).toJS()
    pinboard


  populatePinboards: ->
    user                      = UserStore.me()
    pinboards                 = user.get('pinboards').map @populatePinboard
    pinboards_through_roles   = user.get('pinboards_through_roles').map @populatePinboard
    pinboards                 = pinboards.concat(pinboards_through_roles).toSetSeq().sortBy((p) -> p.title)

    @handleChange('pinboard_id', pinboards.first().id) if pinboards.size > 0

    @setState
      user:       user.deref().toJS()
      pinboards:  pinboards
      ready:      true
      sync:       false


  # Create Pinboard
  #
  createPinboard: ->
    @setState
      sync: true

    PinboardStore.create({ title: @state.attributes.get('pinboard_title') }).then (json) =>
      @sendInsightToPinboard(json.id)


  # Send Insight to Pinboard
  #
  sendInsightToPinboard: (pinboard_id) ->
    @setState
      sync: true

    PinStore.create({ parent_id: @props.pin, pinboard_id: pinboard_id, content: @state.attributes.get('content') }).then =>
      @setState
        sync: false

      @props.onDone()


  # Handle Submit
  #
  handleSubmit: (event) ->
    event.preventDefault()

    return if @state.sync

    if @state.attributes.get('pinboard_id') == 'new'
      @createPinboard() if @state.attributes.get('pinboard_title').length > 0
    else
      @sendInsightToPinboard(@state.attributes.get('pinboard_id'))


  # Handle Change
  #
  handleChange: (field, event_or_value) ->
    value = if typeof event_or_value is 'string' then event_or_value else event_or_value.target.value
    @setState
      attributes: @state.attributes.set(field, value)


  # Lifecycle
  #

  componentDidMount: ->
    @fetch()


  # Render Header
  #
  renderHeader: ->
    <header className="insight-content" style={ pointerEvents: 'none' }>
      <Insight pin={ @props.pin } />
    </header>


  # Render Pinboard
  #

  renderPinboards: ->
    pinboards = @state.pinboards
      .map (pinboard) =>
        user = if pinboard.user_id == @state.user.id then "" else " — #{@state.user.full_name}"
        <option key={ pinboard.id } value={ pinboard.id }>{ pinboard.title + user }</option>

    [<option key='new' value='new'>Create collection</option>].concat(pinboards.toArray())


  renderPinboard: ->
    <label className="pinboard">
      <div className="title">Collection</div>
      <div className="select-wrapper">
        <select value={ @state.attributes.get('pinboard_id') } onChange={ @handleChange.bind(@, 'pinboard_id') }>
          { @renderPinboards() }
        </select>
        <i className="fa fa-angle-down select-icon" />
      </div>
    </label>


  renderNewPinboard: ->
    return null unless @state.attributes.get('pinboard_id') == 'new'

    <label ref='pinboard_title' className="pinboard">
      <div className="title" />
      <div className="input-wrapper">
        <input
          className   = "form-control"
          autoFocus   = "true"
          value       = { @state.attributes.get('pinboard_title') }
          onChange    = { @handleChange.bind(@, 'pinboard_title') }
          placeholder = "Enter collection name"
        />
      </div>
    </label>


  # Render Content
  #
  renderContent: ->
    <label className="comment">
      <div className="title">
        Note
      </div>
      <textarea
        autoFocus = { true}
        rows      = "5"
        value     = { @state.attributes.get('content') }
        onChange  = { @handleChange.bind(@, 'content') }
      />
    </label>

  # Render Footer
  #
  renderFooter: ->
    <footer>
      <button type="button" className="cc cancel" onClick={ @props.onCancel }>Cancel</button>
      <button type="submit" className="cc">Save to collection</button>
    </footer>


  # Render
  #
  render: ->
    return null unless @state.ready

    <form className="pin" onSubmit={ @handleSubmit }>
      { @renderHeader() }

      <fieldset>
        { @renderPinboard() }
        { @renderNewPinboard() }
        { @renderContent() }
      </fieldset>

      { @renderFooter() }
    </form>
