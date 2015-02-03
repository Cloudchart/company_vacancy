# Imports
#
tag = React.DOM

AvatarComponent   = require('components/avatar')
vacancyColor      = require('utils/colors').vacancy


# Main
#
Component = React.createClass


  render: ->
    (tag.div {
      className: 'vacancy identity'
    },
      
      (AvatarComponent {
        backgroundColor: vacancyColor
      },
        (tag.i { className: 'fa fa-briefcase' })
      )

      (tag.header null, @props['name'])
      (tag.footer null, 'Vacancy')
      
    )



# Exports
#
module.exports = Component
