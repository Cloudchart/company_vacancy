# Imports
#
tag = React.DOM


BlockActions  = require('actions/block_actions')

VacancyStore  = require('stores/vacancy')


# Main
#
Component = React.createClass


  gatherVacancies: ->
    _.map @state.vacancies, (vacancy) =>
      (tag.div {
        key:          vacancy.uuid
        className:    'vacancy'
        onClick:      @onVacancyClick.bind(@, vacancy.uuid)
      },
        (tag.i { className: 'fa fa-briefcase' })
        vacancy.name
      )
  
  
  onVacancyClick: (key) ->
    identity_ids = @props.block.identity_ids[..] ; identity_ids.push(key)
    BlockActions.update(@props.block.uuid, { identity_ids: identity_ids })
    

  
  onQueryChange: (event) ->
    @setState({ query: event.target.value })


  getStateFromStores: ->
    vacancies: VacancyStore.filter((vacancy) => vacancy.company_id == @props.block.owner_id)


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
          autoFocus:    true
          value:        @state.query
          onChange:     @onQueryChange
          placeholder:  "Type here..."
        })
      )
      
      (tag.section null,
        @gatherVacancies()
      )
      
    )


# Exports
#
module.exports = Component
