# Imports
#
tag = React.DOM


ModalActions    = require('actions/modal_actions')

VacancyStore    = require('stores/vacancy')

VacancyChooser  = require('components/editor/vacancy_chooser')


# Main
#
Component = React.createClass


  onAddVacancyClick: ->
    ModalActions.show(VacancyChooser({
      block:  @props.block
    }))


  getStateFromStore: ->
    ids = @props.block.identity_ids
    vacancies: VacancyStore.filter (item) -> _.contains(ids, item.uuid)


  getInitialState: ->
    @getStateFromStore()


  render: ->
    console.log @state
    (tag.section {
      className: 'vacancy'
    },
    
      (tag.header null, "Open Positions")
      
      (tag.div {
        className: 'add'
        onClick:    @onAddVacancyClick
      },
        (tag.i { className: 'fa fa-plus' })
        "Add vacancy"
      )
    
    )


# Exports
#
module.exports = Component
