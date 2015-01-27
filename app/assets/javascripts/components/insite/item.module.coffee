# @cjsx React.DOM


# Stores
#
PinStore    = require('stores/pin_store')
UserStore   = require('stores/user_store.cursor')


# Components
#
Avatar      = require('components/avatar')
PinForm     = require('components/form/pin_form')


# Actions
#
Modal       = require('actions/modal_actions')


# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'InsiteItem'
  
  statics:
    getCursor: (id) ->
      pin:    PinStore.cursor.items.cursor(id)
      users:  UserStore.cursor.items
  
  
  repinByCurrentUser: ->
    PinStore.cursor.items
      .find (pin) =>
        pin.get('parent_id')  is @props.cursor.pin.get('uuid')  and
        pin.get('user_id')    is @state.currentUser.get('uuid')
  
  
  hasRepinsByCurrentUser: ->
    !!@repinByCurrentUser()
  

  isPinnedByCurrentUser: ->
    @props.cursor.pin.get('user_id') == @state.currentUser.get('uuid')
  
  
  gatherAttributes: ->
    parent_id:      @props.cursor.pin.get('uuid')
    pinnable_id:    @props.cursor.pin.get('pinnable_id')
    pinnable_type:  @props.cursor.pin.get('pinnable_type')
  
  
  handlePinButtonClick: (event) ->
    event.preventDefault()
    
    if @isPinnedByCurrentUser()
      PinStore.destroy(@props.cursor.pin.get('uuid')) if confirm('Are you sure?')

    else if repin = @repinByCurrentUser()
      PinStore.destroy(repin.get('uuid')) if confirm('Are you sure?')

    else
      Modal.show(
        <PinForm {... @gatherAttributes()}
          title     = { @props.cursor.pin.get('content') }
          onCancel  = { Modal.hide } 
          onDone    = { Modal.hide }
        />
      )
  
  
  getDefaultProps: ->
    currentUserId: if (element = document.querySelector('meta[name="user-id"]')) then element.getAttribute('content')
  
  
  getInitialState: ->
    user:         @props.cursor.users.cursor(@props.cursor.pin.get('user_id'))
    currentUser:  @props.cursor.users.cursor(@props.currentUserId)
  
  
  renderAvatar: ->
    <aside>
      <Avatar
        avatarURL       = { @state.user.get('avatar_url') }
        backgroundColor = "transparent"
        value           = { @state.user.get('full_name') }
      />
    </aside>
  
  
  renderUser: ->
    <section>
      <p className="name">
        { @state.user.get('full_name') }
      </p>
      <p className="occupation">
        { @state.user.get('occupation') }
      </p>
      <p className="comment">
        { @props.cursor.pin.get('content') }
      </p>
    </section>
  
  
  renderButtons: ->
    return null unless @state.currentUser.deref()
    
    classList = cx
      active: @isPinnedByCurrentUser() or @hasRepinsByCurrentUser()
    
    <ul className="round-buttons">
      <li className={ classList } onClick={ @handlePinButtonClick }>
        <i className="fa fa-thumb-tack" />
      </li>
    </ul>
  
  
  render: ->
    return null unless @props.cursor.pin.deref()
    return null unless @state.user.deref()
    
    <li className="insite">
      { @renderAvatar() }
      { @renderUser() }
      { @renderButtons() }
    </li>
