##= require components/QueryInput
##= require components/Person
##= require components/IdentityList
##= require stores/PersonStore

# Imports
# 
tag = React.DOM

QueryInputComponent = cc.require('cc.components.QueryInput')
PersonComponent = cc.require('cc.components.Person')
IdentityListComponent = cc.require('cc.components.IdentityList')
PersonStore = cc.require('cc.stores.PersonStore')

# Main Component
#
MainComponent = React.createClass

  # Component Specifications
  #
  render: ->
    (tag.div { className: 'identity-selector aspect-ratio-1x1' },
      (tag.div { className: 'content' },
        @gatherControls()
      )
    )

  getInitialState: ->
    mode: 'view'
    query: []

  # getDefaultProps: ->

  # Lifecycle Methods
  #
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->

  # Instance Methods
  # 
  gatherControls: ->
    switch @state.mode
    
      when 'edit'
        [
          (QueryInputComponent {
            key:          'query-input'
            placeholder:  'Type name'
            autoFocus:    true
            onChange:     @onQueryChange
            onCancel:     @onQueryCancel
          })

          (IdentityListComponent {
            key:            'people-list'
            onSelect:       @onPersonSelect
          },
            @gatherPeople()
          )

        ]
      
      when 'view'
        @addButton()

  gatherPeople: ->
    people = _.chain(PersonStore.all())
      .reject (person) => _.contains(@props.filtered_people, person.to_param())
      .filter (person) => _.all @state.query, (q) -> person.matches(q)
      .sortBy (person) -> person.sortValue()
      .value()

    _.map people, (person) ->
      (PersonComponent { key: person.to_param() })

  addButton: ->
    (tag.button {
      key:      'add-button'
      onClick:  @onAddButtonClick
    },
      "Add"
      (tag.i { className: 'fa fa-male' })
    )

  onPersonSelectDone: (json) ->
    console.log json
    @props.onChange({ target: { value: json }})
    @setState
      mode: 'view'

  onPersonSelectFail: ->
    console.warn 'onPersonSelectFail'

  # Events
  # 
  onPersonSelect: (key) ->
    $.ajax
      url: "/people/#{key}/make_owner"
      method: 'PUT'
      dataType: 'json'
    .done @onPersonSelectDone
    .fail @onPersonSelectFail

  onAddButtonClick: ->
    @setState
      mode: 'edit'

  onQueryChange: (query) ->
    @setState
      query: query
  
  onQueryCancel: ->
    @setState
      query:  []
      mode:   'view'  

# Exports
#
cc.module('react/company/owners/selector').exports = MainComponent
