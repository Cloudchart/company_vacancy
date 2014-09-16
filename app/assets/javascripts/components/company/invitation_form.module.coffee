# Imports
#
tag = React.DOM


CompanyStore  = require('stores/company_store')
TokenStore    = require('stores/token_store')
TokenActions  = require('actions/token_actions')


# Roles
#
Roles = [
  {
    key:    'public'
    title:  'Allow to view company'
    hint:   'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
  }
  
  {
    key:    'trusted'
    title:  'Allow to see burn rate'
    hint:   'Usually you want to show your spendings to investors or partners'
  }
  
  {
    key:    'editor'
    title:  'Allow to edit company'
    hint:   'Company HR managers or managing partners usually need access to editing'
  }
]


getStateFromStores = (key) ->
  token: TokenStore.get(key)


# Main
#
Component = React.createClass


  gatherRoles: ->
    _.map Roles, (role) =>
      (tag.label {
        key:  role.key
      },
        (tag.input {
          name:     'role'
          type:     'radio'
          value:    role.key
          checked:  role.key == @state.role
          onChange: @onRoleChange
        })

        role.title

        (tag.p null, role.hint )
      )
  

  onSubmit: (event) ->
    event.preventDefault()
    TokenActions.createCompanyInvite(@props.key, @props.company.uuid, {
      data:
        email:  @state.email
        role:   @state.role
    })


  onEmailChange: (event) ->
    @setState({ email: event.target.value })
  
  
  onRoleChange: (event) ->
    @setState({ role: event.target.value })


  getInitialState: ->
    state = getStateFromStores(@props.key)
    state.email = ''
    state.role  = 'public'
    state


  render: ->
    (tag.form {
      className:  'invite'
      onSubmit:   @onSubmit
    },
    
      (tag.header null,
        "You're about to share "
        (tag.strong null, @props.company.name)
        " company and chart"
      )
    
      (tag.fieldset {
      },
      
        @gatherRoles()
        
        (tag.input {
          autoFocus:    true
          className:    'email'
          name:         'email'
          value:        @state.email
          placeholder:  'Email'
          onChange:     @onEmailChange
        })
        
      )
    
      (tag.footer {
      },
        (tag.button {
        },
          'Send invite'
          (tag.i { className: 'fa fa-send-o' })
        )
      )
    
    )


# Exports
#
module.exports = Component
