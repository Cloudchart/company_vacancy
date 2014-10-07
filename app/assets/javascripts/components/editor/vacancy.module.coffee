# Imports
#
tag = React.DOM


ModalActions    = require('actions/modal_actions')
BlockActions    = require('actions/block_actions')

BlockStore      = require('stores/block_store')
VacancyStore    = require('stores/vacancy')

VacancyChooser  = require('components/editor/vacancy_chooser')


# Add Vacancy component
#
AddVacancyComponent = ->
  (tag.div {
    key:        'add'
    className:  'cell'
    onClick:    @onAddVacancyClick
  },
    (tag.div {
      className: 'vacancy add'
    },
      (tag.i { className: 'fa fa-plus' })
      (tag.span null, 'Add vacancy')
    )
  )


# Main
#
Component = React.createClass


  gatherVacancies: ->
    _.chain(@state.vacancies)
      .sortBy (vacancy) => _.indexOf(@state.block.identity_ids, vacancy.uuid)
      .map (vacancy) =>
        (tag.div {
          key:        vacancy.uuid
          className:  'cell'
        },
        
          (tag.div {
            className: 'vacancy'
          },
          
            (tag.figure { className: 'flag' })

            vacancy.name

            (tag.button {
              onClick: @onDeleteButtonClick.bind(@, vacancy.uuid)
            },
              (tag.i { className: 'fa fa-times' })
            ) unless @props.readOnly
          
          )
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
    vacancies = @gatherVacancies()

    if @props.readOnly and vacancies.length == 0
      (tag.noscript null)
    else

      (tag.section {
      },
    
        (tag.header null, "Open Positions")
      
        (tag.div {
          className: 'editor-vacancies'
        },

          @gatherVacancies()
        
          AddVacancyComponent.apply(@) unless @props.readOnly
      
        )

      )


# Exports
#
module.exports = Component
