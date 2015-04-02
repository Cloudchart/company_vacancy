# @cjsx React.DOM


# Imports
#
GlobalState = require('global_state/state')
CloudRelay  = require('cloud_relay')


# Stores
#
UserStore   = require('stores/user_store.cursor')
TokenStore  = require('stores/token_store.cursor')


# Components
#
ViewComponent = require('components/invite_queue/view')
EditComponent = require('components/invite_queue/edit')


# Utils
#

findEmailVerificationTokenFor = (user_id) ->
  TokenStore.cursor.items.find (token) ->
    token.get('owner_type') == 'User' and
    token.get('owner_id') == user_id and
    token.get('name') == 'email_verification'


# Fields
#
Fields = Immutable.Seq({ full_name: 'Name Surname', company: 'Company', occupation: 'Occupation', email: 'Email' })


# Main Component
#
MainComponent = React.createClass

  displayName: 'InviteQueueApp'


  mixins: [GlobalState.mixin]


  componentWillMount: ->
    @cursor =
      user:     UserStore.cursor.items.cursor(@props.user)
      tokens:   TokenStore.cursor.items



  getInitialState: ->
    mode: 'view'


  switchMode: (newMode) ->
    @setState
      mode: newMode


  getUser: ->
    user        = @cursor.user.deref().toJS()
    user.email  = if token = findEmailVerificationTokenFor(@cursor.user.get('uuid')) then token.getIn(['data', 'address'], '') else ''
    user


  render: ->
    return null unless @cursor.user.deref(false)

    mode = if @cursor.user.get('created_at') is @cursor.user.get('updated_at')
      'edit'
    else
      @state.mode

    switch mode
      when 'view'
        <ViewComponent user = { @getUser() } onClick={ @switchMode.bind(@, 'edit') } />
      when 'edit'
        <EditComponent user = { @getUser() } onChange={ @switchMode.bind(@, 'view') } />


# Exports
#
module.exports = CloudRelay.createContainer MainComponent,

  queries:

    user: ->
      """
        User {
          tokens
        }
      """
