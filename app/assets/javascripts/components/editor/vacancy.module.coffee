# Imports
#
tag = React.DOM


ModalActions    = require('actions/modal_actions')
BlockActions    = require('actions/block_actions')

BlockStore      = require('stores/block_store')
VacancyStore    = require('stores/vacancy')

VacancyChooser  = require('components/editor/vacancy_chooser')


# Vacancy Placeholder component
#
VacancyPlaceholderComponent = ->
  (tag.li {
    className:  'placeholder'
    onClick:    @onAddVacancyClick
  },
    (div {
      className: 'vacancy'
    },
      (div {
        className: 'content'
      },
        (tag.footer null, 'Add vacancy')
      )
    )
  )


# Vacancy component
#
VacancyComponent = (vacancy) ->
  (tag.div {
    className:  'vacancy'
    onClick:    null # Edit vacancy
  },
    (tag.i { className: 'flag' })
  
    (tag.i {
      className: 'fa fa-times remove'
      onClick:    @handleVacancyRemove.bind(@, vacancy.getKey())
    }) unless @props.readOnly

    (tag.div {
      className: 'content'
    },
      (tag.footer null, vacancy.name)
    )
  )



# Main
#
Component = React.createClass

  statics:
    isEmpty: (block_id) ->
      block = BlockStore.get(block_id)
      VacancyStore.filter((item) => block.identity_ids.contains(item.uuid)).length == 0 #_.contains(block.identity_ids, item.uuid)).length == 0


  gatherVacancies: ->
    _.chain(@state.vacancies)
      .sortBy (vacancy) => @state.block.identity_ids.indexOf(vacancy.uuid)#_.indexOf(@state.block.identity_ids, vacancy.uuid)
      .map (vacancy) =>
        (tag.li {
          key: vacancy.getKey()
        },
          VacancyComponent.call(@, vacancy)
        )
      .value()
  
  
  handleVacancyRemove: (key) ->
    identity_ids  = @state.block.identity_ids.remove(@state.block.identity_ids.indexOf(key))
    BlockActions.update(@props.key, { identity_ids: identity_ids.toJS() })


  onAddVacancyClick: ->
    ModalActions.show(VacancyChooser({
      key: @props.key
      company_id: @props.company_id
    }))


  getStateFromStores: ->
    block = BlockStore.get(@props.key)
    block:      block
    vacancies:  VacancyStore.filter (item) => block.identity_ids.contains(item.uuid)
  
  
  componentWillReceiveProps: ->
    @setState(@getStateFromStores())


  getInitialState: ->
    @getStateFromStores()


  render: ->
    (tag.ul { className: 'vacancies' },
      @gatherVacancies()
      VacancyPlaceholderComponent.apply(@) unless @props.readOnly
    )


# Exports
#
module.exports = Component
