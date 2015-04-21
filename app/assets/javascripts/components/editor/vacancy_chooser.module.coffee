# Imports
#
tag = React.DOM


BlockActions  = require('actions/block_actions')
ModalActions  = require('actions/modal_actions')

BlockStore    = require('stores/block_store')
VacancyStore  = require('stores/vacancy')

VacancyForm   = require('components/form/vacancy_form')


# Main
#
Component = React.createClass


  gatherVacancies: ->
    queries = _.compact(@state.query.toLowerCase().split(/\s+/))
    
    _.chain (@state.vacancies)
      .reject (vacancy) => @state.block.identity_ids.contains(vacancy.uuid) #_.contains(@state.block.identity_ids, vacancy.uuid)
      .filter (vacancy) -> _.all queries, (query) -> vacancy.name.toLowerCase().indexOf(query) >= 0
      .sortBy (vacancy) -> vacancy.name
      .map (vacancy) =>
        (tag.li {
          key:          vacancy.uuid
          className:    'vacancy'
          onClick:      @onVacancyClick.bind(@, vacancy.uuid)
        },
          (tag.i { className: 'fa fa-briefcase' })
          vacancy.name
        )
      .value()
  
  
  focus: ->
    @refs['query-input'].getDOMNode().focus()
  

  onNewVacancyClick: ->
    newVacancyKey = VacancyStore.create({ company_id: @state.block.owner_id })

    component = VacancyForm
      uuid:      newVacancyKey
      onCreate:  -> setTimeout ModalActions.hide
        

    ModalActions.show component,
      beforeHide: ->
        VacancyStore.remove(newVacancyKey)
  
  
  onVacancyClick: (key) ->
    #identity_ids = @state.block.identity_ids[..] ; identity_ids.push(key)
    identity_ids = @state.block.identity_ids.push(key)
    BlockActions.update(@props.uuid, { identity_ids: identity_ids.toJS() })
    ModalActions.hide()

  
  onQueryChange: (event) ->
    @setState({ query: event.target.value })
  
  
  componentDidMount: ->
    BlockStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnmount: ->
    BlockStore.off('change', @refreshStateFromStores)
  
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())


  getStateFromStores: ->
    block = BlockStore.get(@props.uuid)

    block:      block
    vacancies:  VacancyStore.filter((vacancy) => vacancy.company_id == @props.company_id)


  getInitialState: ->
    state         = @getStateFromStores()
    state.query   = ''
    state


  render: ->
    (tag.div {
      className: 'chooser'
    },
      
      (tag.header null,
        (tag.input {
          ref:          'query-input'
          autoFocus:    true
          value:        @state.query
          onChange:     @onQueryChange
          placeholder:  "Type here..."
        })
      )
      
      (tag.section null,
        (tag.ul null,
          (tag.li {
            className:  'new'
            onClick:    @onNewVacancyClick
          },
            (tag.i { className: 'fa fa-plus' })
            "New vacancy"
          )
          @gatherVacancies()
        )
      )
      
    )


# Exports
#
module.exports = Component
