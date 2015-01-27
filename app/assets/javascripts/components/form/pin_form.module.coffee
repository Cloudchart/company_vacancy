# @cjsx React.DOM


GlobalState   = require('global_state/state')


PinboardStore = require('stores/pinboard_store')
PinStore      = require('stores/pin_store')


ModalActions  = require('actions/modal_actions')

# Constants
#
ContentMaxLength = 120


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
    
    if (@state.attributes.get('pinboard_id') == 'new')
      PinboardStore.create({ title: @state.attributes.get('pinboard_title') }).then(@handlePinboardSave, @handleSaveFail)
    else
      attributes = @state.attributes.remove('pinboard_name').toJSON()
      @createPin(attributes)
  

  createPin: (attributes) ->
    PinStore.create(attributes).then(@props.onDone, @handlePinSaveFail)
  
  
  handlePinboardSave: (json) ->
    attributes = @state.attributes
      .remove('pinboard_name')
      .set('pinboard_id', json.id)
      .toJSON()

    @createPin(attributes)
  
  
  handleSaveFail: ->
    snabbt(@getDOMNode().parentNode, 'attention', {
      position: [50, 0, 0]
      springConstant: 3
      springDeacceleration: .9
    })
  

  handleChange: (name, event) ->
    value = event.target.value

    if name == 'content' and value.length > ContentMaxLength
      value = value.substring(0, ContentMaxLength)
    
    @setState
      attributes: @state.attributes.set(name, value)
  
  
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
      parent_id:      @props.parent_id
      pinboard_id:    @props.pinboard_id    || getDefaultPinboardId() || ''
      pinnable_id:    @props.pinnable_id
      pinnable_type:  @props.pinnable_type
      content:        @props.content        || ''
      pinboard_title: ''
  
  
  renderHeader: ->
    <header>
      <div>Pin It</div>
      <div className="title">{ unwrapTitle(@props.title) }</div>
    </header>


  renderPinboardsOptions: ->
    options = @props.cursor
      .sortBy (pinboard) -> pinboard.get('title')
      .map (pinboard, uuid) ->
        <option key={ uuid } value={ uuid }>{ pinboard.get('title') }</option>
      .toList()
    
    options = options.push(<option key="new" value="new">Create Category</option>)
    
    options
  
  
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
  
  
  renderPinboardInput: ->
    return null unless @state.attributes.get('pinboard_id') == 'new'
    
    <label className="pinboard">
      <span className="title" />
      <div className="input-wrapper">
        <input
          className   = "form-control"
          autoFocus   = "true"
          value       = { @state.attributes.get('pinboard_title') }
          onChange    = { @handleChange.bind(@, 'pinboard_title') }
          placeholder = "Pick a name"
        />
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
      <span className="counter">{ ContentMaxLength - @state.attributes.get('content').length }</span>
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
        { @renderPinboardInput() }
        { @renderPinComment() }
      </fieldset>

      { @renderFooter() }
    </form>
