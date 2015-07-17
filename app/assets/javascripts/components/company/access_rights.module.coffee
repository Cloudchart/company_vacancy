# @cjsx React.DOM

# Imports
#
GlobalState      = require('global_state/state')

RolesAccessList = require('components/roles/access_list')
RolesInviteForm = require('components/roles/invite_form')

Modes = 
  VIEW:   'view'
  INVITE: 'invite'

ownerType  = 'Company'
roleValues = ['editor', 'trusted_reader', 'public_reader']

# Main
#
Component = React.createClass

  displayName: 'PinboardRoles'

  propTypes:
    uuid: React.PropTypes.string.isRequired

  mixins: [GlobalState.query.mixin]

  statics:

    queries:

      company: ->
        """
          Company {
            roles {
              user
            },
            tokens {
              target
            }
          }
        """

  propTypes:
    uuid: React.PropTypes.any.isRequired

  getInitialState: ->
    mode: Modes.VIEW
    isLoaded: false

  changeMode: (mode) ->
    @setState mode: mode

  fetch: ->
    GlobalState.fetch(@getQuery('company'), { id: @props.uuid })

  isLoaded: ->
    @state.isLoaded


  # Lifecyle methods
  #
  componentWillMount: ->
    @fetch().then => @setState isLoaded: true


  render: ->
    return null unless @isLoaded()

    <section className="access-rights">
      {
        switch @state.mode
        
          when Modes.VIEW
            <RolesAccessList
              ownerId        = { @props.uuid }
              ownerType      = { ownerType }
              roleValues     = { roleValues }
              onInviteClick  = { @changeMode.bind(@, Modes.INVITE) } />

          when Modes.INVITE
            <RolesInviteForm
              ownerId     = { @props.uuid }
              ownerType   = { ownerType }
              roleValues  = { roleValues }
              onBackClick = { @changeMode.bind(@, Modes.VIEW) } />
      }
    </section>

# Exports
#
module.exports = Component
