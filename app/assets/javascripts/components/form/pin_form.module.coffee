# @cjsx React.DOM


GlobalState   = require('global_state/state')


PinboardStore = require('stores/pinboard_store')


ModalActions  = require('actions/modal_actions')



PinboardsSelect = (self, items) ->
  options = items.map (item) ->
    <option key={ item.get('uuid') } value={ item.get('uuid') }>
      { item.get('title') }
    </option>

  <select>
    { options.toArray() }
  </select>



# Exports
#
module.exports = React.createClass


  mixins: [GlobalState.mixin]


  handleSubmit: (event) ->
    event.preventDefault()
  
  
  handleCancelButtonClick: ->
    ModalActions.hide()
  
  
  onGlobalStateChange: ->
    clearTimeout @__global_state_change_timeout

    @__global_state_change_timeout = setTimeout =>
      @setState
        globalStateChangedAt: + new Date
  
  
  componentDidMount: ->
    PinboardStore.fetchAll() unless @props.cursor.pinboards.deref()
  
  
  getDefaultProps: ->
    cursor:
      pinboards: PinboardStore.cursor.items
  
  
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
          <textarea></textarea>
        </label>
      
      </fieldset>
      
      <footer>
        <button type="button" onClick={ @handleCancelButtonClick }>Cancel</button>
        <button type="submit">Pin It</button>
      </footer>
    </form>
