##= require ./form

# Imports
#
tag = cc.require('react/dom')

ActivationFormComponent = cc.require('react/profile/activation/form')


# Main Component
#
MainComponent = React.createClass

  render: ->
    (tag.section { className: 'welcome' },
      (tag.h1 {}, @props.title)
      (tag.p {}, @props.note)
      
      (ActivationFormComponent {
        user:   @props.user
      })
    )


# Exports
#
cc.module('react/profile/activation/main').exports = MainComponent
