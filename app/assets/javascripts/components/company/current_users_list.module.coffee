# Imports
#
tag = React.DOM


TokenStore    = require('stores/token_store')
TokenItem     = require('components/company/token_item')


# Main
#
Component = React.createClass


  currentTokens: ->
    _.map @props.tokens, (token, key) ->
      (TokenItem {
        key:    key
        email:  token.data.email
        role:   token.data.role
        sync:   TokenStore.getSync(key)
        company:
          key:  token.owner_id
      })
  
  
  render: ->
    (tag.table {
      className: 'current-users-list'
    },
      (tag.tbody {
      },
        @currentTokens()
      )
    )


# Exports
#
module.exports = Component
