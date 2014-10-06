# Imports
#
tag = React.DOM


ModalActions = require('actions/modal_actions')

PersonChooser = require('components/editor/person_chooser')


# Main
#
Component = React.createClass


  onAddPersonClick: (event) ->
    ModalActions.show(PersonChooser({
      key:  @props.key
    }))
    


  render: ->
    (tag.section {
      className: 'people'
    },
    
      (tag.div {
        className: 'add'
        onClick:    @onAddPersonClick
      },
        (tag.i { className: 'fa fa-plus' })
        'Add person'
      )
    
    )


# Exports
#
module.exports = Component
