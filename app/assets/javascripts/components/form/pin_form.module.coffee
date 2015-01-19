# @cjsx React.DOM


GlobalState   = require('global_state/state')


PinboardStore = require('stores/pinboard_store')
PinStore      = require('stores/pin_store')


ModalActions  = require('actions/modal_actions')



PinboardsSelect = (self, items) ->
  options = items
    .sortBy (item) -> item.get('title')
    .map (item) ->
      <option key={ item.get('uuid') } value={ item.get('uuid') }>
        { item.get('title') }
      </option>
  
  <select onChange={self.handleChange.bind(null, 'pinboard_id')} value={self.state.pinboard_id}>
    { options.toArray() }
  </select>



# Exports
#
module.exports = React.createClass


  mixins: [GlobalState.mixin]
  
  
  handleCreateDone: ->
    @handleCancelButtonClick()
  

  handleCreateFail: ->
    alert 'FAIL!!!'


  handleSubmit: (event) ->
    event.preventDefault()

    PinStore.create({
      pinnable_id:    @props.pinnable_id
      pinnable_type:  @props.pinnable_type
      pinboard_id:    @state.pinboard_id
      content:        @state.content
    }).then(@handleCreateDone, @handleCreateFail)
    
  
  
  handleCancelButtonClick: ->
    ModalActions.hide()
  
  
  handleChange: (name, event) ->
    nextState       = {}
    nextState[name] = event.target.value
    @setState nextState
  
  
  getStateFromCursor: ->
    pinboard_id: (@state and @state.pinboard_id) || if pinboards = @props.cursor.pinboards.deref() then pinboards.sortBy((item) -> item.get('title')).first().get('uuid') else ''
  
  
  onGlobalStateChange: ->
    clearTimeout @__global_state_change_timeout

    @__global_state_change_timeout = setTimeout =>
      @setState @getStateFromCursor()
  
  
  componentDidMount: ->
    PinboardStore.fetchAll() unless @props.cursor.pinboards.deref()
  
  
  getDefaultProps: ->
    cursor:
      pinboards: PinboardStore.cursor.items
  

  getInitialState: ->
    state           = @getStateFromCursor()
    state.content   = ''
    state
  
  
  render: ->
    pinboards = @props.cursor.pinboards.deref()
    
    board = if pinboards
      if pinboards.size > 0
        <label>
          <span>Choose a Board</span>
          { PinboardsSelect(@, pinboards) }
        </label>
      else
        <label>
          <span>Name a Board</span>
          <input autoFocus="true" />
        </label>
    else
      null

    
    <form onSubmit={ @handleSubmit }>
      <header>
        Pin It
      </header>
      
      <fieldset>

        { board }
        
        <br />
        
        <label>
          <span>Add Comments</span>
          <textarea value={@state.content} onChange={@handleChange.bind(null, 'content')} />
        </label>
      
      </fieldset>
      
      <footer>
        <button type="button" onClick={ @handleCancelButtonClick }>Cancel</button>
        <button type="submit">Pin It</button>
      </footer>
    </form>
