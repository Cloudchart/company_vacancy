# Imports
#
tag = React.DOM


ModalActions    = require('actions/modal_actions')
BlockActions    = require('actions/block_actions')

VacancyStore    = require('stores/vacancy')

VacancyChooser  = require('components/editor/vacancy_chooser')


# Main
#
Component = React.createClass


  gatherVacancies: ->
    _.chain(@state.vacancies)
      .sortBy (vacancy) => _.indexOf(@props.block.identity_ids, vacancy.uuid)
      .map (vacancy) =>
        (tag.div {
          key: vacancy.uuid
        },
          (tag.i { className: 'fa fa-briefcase' })
          vacancy.name
          (tag.button {
            onClick: @onDeleteButtonClick.bind(@, vacancy.uuid)
          })
        )
      .value()
  
  
  onDeleteButtonClick: (key) ->
    identity_ids  = _.without(@props.block.identity_ids, key)
    attributes    = if identity_ids.length == 0
      { clear_identity_ids: true }
    else
      { identity_ids: identity_ids }

    BlockActions.update(@props.block.uuid, attributes)


  onAddVacancyClick: ->
    ModalActions.show(VacancyChooser({
      block:  @props.block
    }))


  getStateFromStore: ->
    vacancies: VacancyStore.filter (item) => _.contains(@props.block.identity_ids, item.uuid)


  getInitialState: ->
    @getStateFromStore()


  render: ->
    (tag.section {
      className: 'vacancy'
    },
    
      (tag.header null, "Open Positions")
      
      @gatherVacancies()
      
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
