# Imports
#
tag = React.DOM


ModalActions    = require('actions/modal_actions')
BlockActions    = require('actions/block_actions')

BlockStore      = require('stores/block_store')
VacancyStore    = require('stores/vacancy')

VacancyChooser  = require('components/editor/vacancy_chooser')


# Main
#
Component = React.createClass


  gatherVacancies: ->
    _.chain(@state.vacancies)
      .sortBy (vacancy) => _.indexOf(@state.block.identity_ids, vacancy.uuid)
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
    identity_ids  = _.without(@state.block.identity_ids, key)
    BlockActions.update(@state.block.uuid, { identity_ids: identity_ids })


  onAddVacancyClick: ->
    ModalActions.show(VacancyChooser({
      key:  @props.key
    }))


  getStateFromStores: ->
    block = BlockStore.get(@props.key)
    block:      block
    vacancies:  VacancyStore.filter (item) => _.contains(block.identity_ids, item.uuid)
  
  
  componentWillReceiveProps: ->
    @setState(@getStateFromStores())


  getInitialState: ->
    @getStateFromStores()


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
