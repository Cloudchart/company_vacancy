# @cjsx React.DOM

# Imports
#
tag = React.DOM

Buttons = require('components/company/buttons')
Actions = require('actions/roles')
RoleMap = require('utils/role_map')


# Main
#
Component = React.createClass

  getDefaultProps: ->
    invitable_roles: []

  onRevokeButtonClick: ->
    Actions.delete(@props.key)

  onSelectRoleChange: (e) ->
    Actions.update(@props.key, {value: e.target.value })

  getOptions: ->
    _.map(@props.invitable_roles, (role) =>
      <option value={role} key="option-#{role}" >{RoleMap[role].name}</option>
    )

  render: ->
    (tag.tr {
      className: 'role'
    },
      
      (tag.td {
        className: 'name'
      },
        @props.user.full_name

        (tag.span {
          className: 'email'
        },
          @props.user.email
        )
      )
      
      
      (tag.td {
        className: 'user-role'
      },
        if @props.role == "owner"
          RoleMap[@props.role].name
        else
          [
            tag.select { 
              key: 'select'
              value: @props.role
              onChange: @onSelectRoleChange
            }, @getOptions()
            tag.i { key: 'icon', className: "fa fa-chevron-down" }
          ]
      )
      
      (tag.td {
        className: 'actions'
      },
      
        (Buttons.SyncButton {
          className: 'cc-table revoke'
          title:    'Revoke'
          sync:     @props.sync == 'revoke'
          disabled: @props.sync
          onClick:  @onRevokeButtonClick
        }) unless @props.role == 'owner'
      
      )
      
    )


# Exports
#
module.exports = Component
