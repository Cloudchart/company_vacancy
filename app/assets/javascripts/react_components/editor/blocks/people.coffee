# Expose
#
tag = React.DOM


# Person component
#
PersonComponent = React.createClass


  onDeleteClick: ->
    @props.onPersonDelete({ target: { value: @props.model.uuid }}) if @props.onPersonDelete instanceof Function


  render: ->
    (tag.div { className: 'container' },
      (tag.div {},
        (tag.button {
          className:  'change'
          onClick:    @onChangeClick
        },
          "Change"
        ) if false

        (tag.button {
          className:  'delete'
          onClick:    @onDeleteClick
        },
          "Delete"
        )
        (tag.div { className: 'name' },
          @props.model.first_name
          " "
          (tag.strong {}, @props.model.last_name)
        )
        (tag.div { className: 'occupation' },
          @props.model.occupation
        ) if @props.model.occupation
      )
    )


# Person selector component
#
PersonSelectorComponent = React.createClass
  
  
  toggleState: ->
    @setState
      searching: !@state.searching
  
  
  preventIdentitySearchBlur: (event) ->
    event.preventDefault() if @state.searching unless event.target == event.currentTarget
  

  onSearch: (search_result) ->
    if search_result.Person
      search_result.Person = search_result.Person.filter (uuid) => @props.people.indexOf(uuid) == -1

    @setState
      identities: search_result
  
  
  getInitialState: ->
    identities: []
    searching:  false
  
  
  onMouseDown: (event) ->
    event.preventDefault() if @refs.search.state.active
  

  onPersonClick: (event) ->
    @refs.search.blur()
    @props.onPersonSelect(event) if @props.onPersonSelect instanceof Function
    @setState
      identities: []
  
  
  componentDidUpdate: ->
    @refs.search.focus() if @state.searching
  
  
  render: ->
    (tag.div { className: 'container' },
      (tag.div {
        onMouseDown:  @preventIdentitySearchBlur
      },

        (cc.react.shared.IdentitySearch {
          ref:          'search'
          placeholder:  'Type name'
          models:       { Person: @props.url }
          onSearch:     @onSearch
          onBlur:       @toggleState
        }) if @state.searching

        (cc.react.shared.IdentityList {
          onClick:    @onPersonClick
          identities: @state.identities
        }) if @state.searching

        (tag.button {
          className:    'add'
          onClick:      @toggleState
        },
          "Add "
          (tag.i { className: 'fa fa-male' })
        ) unless @state.searching


      )
    )
  

# People component
#
Component = React.createClass

  
  onSaveDone: (json) ->
    @setState
      people: json.identities
  
  
  onSaveFail: ->


  save: ->
    uuids = @state.people.map((person) -> person.uuid)

    $.ajax
      url:              @props.url
      type:             'PUT'
      dataType:         'JSON'
      data:
        block:
          identity_ids: if uuids.length == 0 then [''] else uuids
    .done @onSaveDone
    .fail @onSaveFail


  gatherPeople: (event) ->
    @state.people.map (person) =>
      (tag.div {
        key:            person.uuid
        className: 'container'
      },
        cc.react.editor.blocks.Person
          onDelete:   @onPersonDelete
          onChange:   @onPersonChange
          model:      person
      )
  
  
  onPersonSelect: (event) ->
    people = @state.people.slice(0)
    people.push(event.target.value)
    @setState
      people: people
  
  
  onPersonDelete: (event) ->
    person  = @state.people.filter((person) -> person.uuid == event.target.value)[0] ; return unless person
    people  = @state.people.slice(0)
    
    people.splice(people.indexOf(person), 1)
    
    @setState
      people: people
  
  
  onPersonChange: (event) ->
    alert 'Not implemented yet.'
    


  getInitialState: ->
    people: @props.identities
  
  
  componentDidUpdate: (prevProps, prevState) ->
    prev_uuids  = prevState.people.map((person) -> person.uuid).sort()
    uuids       = @state.people.map((person) -> person.uuid).sort()

    @save() if prev_uuids < uuids or prev_uuids > uuids
  

  render: ->
    (tag.div { className: 'people' },
      @gatherPeople()
      (PersonSelectorComponent {
        people:         @state.people.map((person) -> person.uuid)
        onPersonSelect: @onPersonSelect
        url:            @props.collection_url
      })
    )


# Expose
#
cc.react.editor.blocks.People = Component
