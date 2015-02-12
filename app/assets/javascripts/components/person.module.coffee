# Imports
#
tag = React.DOM


AvatarComponent = require('components/avatar')


# Main
#
Component = React.createClass


  render: ->
    (tag.div {
      className: 'person identity'
    },

      (AvatarComponent {
        value: @props['full_name']
      })

      (tag.header null, @props['full_name'])
      (tag.footer null, @props['occupation'])

    )



# Exports
#
module.exports = Component
