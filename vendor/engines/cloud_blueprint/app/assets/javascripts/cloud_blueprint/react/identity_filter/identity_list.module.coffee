# Imports
#
tag = React.DOM

PersonStore       = require('stores/person_store')
VacancyStore      = require('stores/vacancy_store')

PersonComponent   = require('components/person')
VacancyComponent  = require('components/vacancy')


# Functions
#
getStateFromStores = ->
  people:     _.invoke PersonStore.all(), 'attr'
  vacancies:  _.invoke VacancyStore.all(), 'attr'


# Main
#
Component = React.createClass


  search: (query) ->
    @setState({ query: query })
    
  
  gatherVacancies: ->
    _(@state.vacancies)
      .sortBy(VacancyStore.attributesForSort)
      .map (vacancy_props) ->
        key = vacancy_props[VacancyStore.unique_key]
        (tag.li {
          key:                key
          className:          'draggable'
          'data-id':          key
          'data-behaviour':   'draggable'
          'data-class-name':  'Vacancy'
        },
          (VacancyComponent vacancy_props)
        )
      .value()
  
  
  gatherPeople: ->
    _(@state.people)
      .sortBy(PersonStore.attributesForSort)
      .map (person_props) ->
        key = person_props[PersonStore.unique_key]
        (tag.li {
          key:                key
          className:          'draggable'
          'data-id':          key
          'data-behaviour':   'draggable'
          'data-class-name':  'Person'
        },
          (PersonComponent person_props)
        )
      .value()
  
  
  onStoresChange: ->
    @setState(getStateFromStores())
  
  
  componentDidMount: ->
    PersonStore.on('change', @onStoresChange)
    VacancyStore.on('change', @onStoresChange)


  componentWillUnount: ->
    PersonStore.off('change', @onStoresChange)
    VacancyStore.off('change', @onStoresChange)


  getInitialState: ->
    state       = getStateFromStores()
    state.query = @props.query || []
    state
  
  
  render: ->
    (tag.ul {
      className: 'identity-list'
    },
      @gatherVacancies()
      @gatherPeople()
    )


# Exports
#
module.exports = Component
