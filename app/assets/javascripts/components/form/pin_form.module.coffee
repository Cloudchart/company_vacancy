# @cjsx React.DOM


GlobalState   = require('global_state/state')


PinboardStore = require('stores/pinboard_store')
PinStore      = require('stores/pin_store')


ModalActions  = require('actions/modal_actions')


# Utils
#
titleRE = /^(?:<div>)?([^<]+)(?:<\/div>)?$/

unwrapTitle = (title) ->
  (titleRE.exec(title) || [title, ''])[1]


getDefaultPinboardId = ->
  if pinboard = PinboardStore.cursor.items.sortBy((pinboard) -> pinboard.get('title')).first()
    pinboard.get('uuid')


# Exports
#
module.exports = React.createClass


  mixins: [GlobalState.mixin]
  
  
  handleSubmit: (event) ->
    event.preventDefault()
    PinStore.create(@state.attributes.toJSON()).then(@props.onDone, @handleSaveFail)
  
  
  handleSaveFail: ->
  
  
  handleChange: (name, event) ->
    @setState
      attributes: @state.attributes.set(name, event.target.value)
  
  
  onGlobalStateChange: ->
    @setState
      globalStateChangedAt: + new Date
    
    unless @state.attributes.get('pinboard_id')
      @setState
        attributes: @state.attributes.set('pinboard_id', getDefaultPinboardId())


  componentDidMount: ->
    PinboardStore.fetchAll() unless @props.cursor.deref()


  getDefaultProps: ->
    cursor:       PinboardStore.cursor.items
    title:        ''
  
  
  getInitialState: ->
    attributes: Immutable.Map
      pinboard_id:    @props.pinboard_id    || getDefaultPinboardId()
      pinnable_id:    @props.pinnable_id
      pinnable_type:  @props.pinnable_type
      content:        @props.content
  
  
  renderHeader: ->
    <header>
      <div>Pin It</div>
      <div className="title">{ unwrapTitle(@props.title) }</div>
    </header>


  renderPinboardsOptions: ->
    @props.cursor
      .sortBy (pinboard) -> pinboard.get('title')
      .map (pinboard, uuid) ->
        <option key={ uuid } value={ uuid }>{ pinboard.get('title') }</option>
  
  
  renderPinboardSelect: ->
    <label className="pinboard">
      <span className="title">Pick a Category</span>
      <div className="select-wrapper">
        <select
          value     ={ @state.attributes.get('pinboard_id') }
          onChange  ={ @handleChange.bind(@, 'pinboard_id') }
        >
          { @renderPinboardsOptions().toArray() }
        </select>
        <i className="fa fa-angle-down select-icon" />
      </div>
    </label>
  
  
  renderPinComment: ->
    <label className="comment">
      <span className="title">Add Comments</span>
      <textarea
        rows      = 5
        onChange  = { @handleChange.bind(@, 'content') }
        value     = { @state.attributes.get('content', '') }
      />
    </label>


  renderFooter: ->
    <footer>
      <button key="cancel" type="button" className="cc cancel" onClick={ @props.onCancel }>Cancel</button>
      <button key="submit" type="submit" className="cc">Pin It</button>
    </footer>


  render: ->
    <form className="pin" onSubmit={ @handleSubmit }>
      { @renderHeader() }

      <fieldset>
        { @renderPinboardSelect() }
        { @renderPinComment() }
      </fieldset>

      { @renderFooter() }
    </form>
