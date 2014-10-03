# Imports
#
tag = React.DOM


BlockActions  = require('actions/block_actions')
ModalActions  = require('actions/modal_actions')

BlockStore    = require('stores/block_store')
VacancyStore  = require('stores/vacancy')


# Main
#
Component = React.createClass


  gatherVacancies: ->
    _.chain (@state.vacancies)
      .reject (vacancy) => _.contains(@state.block.identity_ids, vacancy.uuid)
      .map (vacancy) =>
        (tag.div {
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
    
  
  
  onVacancyClick: (key) ->
    identity_ids = @state.block.identity_ids[..] ; identity_ids.push(key)
    BlockActions.update(@props.key, { identity_ids: identity_ids })
    @focus()
    

  
  onQueryChange: (event) ->
    @setState({ query: event.target.value })
  
  
  componentDidMount: ->
    BlockStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnmount: ->
    BlockStore.off('change', @refreshStateFromStores)
  
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())


  getStateFromStores: ->
    block = BlockStore.get(@props.key)

    block:      block
    vacancies:  VacancyStore.filter((vacancy) => vacancy.company_id == block.owner_id)


  getInitialState: ->
    state         = @getStateFromStores()
    state.query   = ''
    state


  render: ->
    (tag.div {
      className: 'vacancy-chooser'
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
        (tag.div {
          onClick:  @onNewVacancyClick
        },
          (tag.i { className: 'fa fa-plus' })
          "New vacancy"
        )
        @gatherVacancies()
      )
      
    )


# Exports
#
module.exports = Component
