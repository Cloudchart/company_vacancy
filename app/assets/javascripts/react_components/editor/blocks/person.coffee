# Expose
#
tag = React.DOM


# Filter people
#
filterPeople = (query) ->
  query_parts = query.split(' ').map((part) -> part.trim()).filter((part) -> part.length) ; return [] if query_parts.length == 0
  people      = Object.keys(cc.models.Person.instances).map (uuid) -> cc.models.Person.get(uuid)
  
  query_parts.forEach (part) ->
    part    = part.toLowerCase()
    people  = people.filter (person) ->
      ['first_name', 'last_name', 'occupation'].some (attribute) ->
        person[attribute].toLowerCase().indexOf(part) > -1 if person[attribute]
  
  people


# Person item
#
PersonSearchItemConponent = React.createClass


  getDefaultProps: ->
    model: cc.models.Person.get(@props.key)


  letters: ->
    @_letters ||= @props.model.first_name.charAt(0).toUpperCase() + @props.model.last_name.charAt(0).toUpperCase()


  onClick: (event) ->
    @props.onClick({ target: { value: @props.key }}) if @props.onClick instanceof Function


  render: ->
    (tag.li {
      onMouseDown: @onClick
    },
      (tag.aside {}, @letters())

      (tag.div { className: 'name' },
        @props.model.first_name
        " "
        (tag.strong {}, @props.model.last_name)
      ) if @props.model.first_name and @props.model.last_name

      (tag.div { className: 'occupation' },
        @props.model.occupation
      ) if @props.model.occupation
    )


# New person component
#
NewPersonComponent = React.createClass


  getInitialState: ->
    people:   false
    editor:   false
    query:    ''
  
  
  onChange: (event) ->
    @setState
      query:  event.target.value
  
  
  onClick: (event) ->
    @setState
      editor: true
  

  onBlur: (event) ->
    @setState
      editor: false
  

  onKeyUp: (event) ->
    @setState { editor: false } if event.which == 27
  
  
  onPersonSelect: (event) ->
    @props.onPersonSelect(event) if @props.onPersonSelect instanceof Function
  
  
  componentDidMount: ->
    cc.models.Person.load(@props.url).done => @setState { people: true }
  
    
  componentDidUpdate: (prevProps, prevState) ->
    @getDOMNode().querySelector('input').focus() if @state.editor
  
  
  gatherPeople: ->
    filterPeople(@state.query).map (person) =>
      PersonSearchItemConponent({ key: person.uuid, onClick: @onPersonSelect })
      

  render: ->
    (tag.div {
      onClick: @onClick
    },
      (tag.header {},
        (tag.input {
          type:         'text'
          placeholder:  'Type name'
          value:        @state.query
          onChange:     @onChange
          onBlur:       @onBlur
          onKeyUp:      @onKeyUp
        })
        (tag.ul {},
          @gatherPeople()
          (tag.li { className: 'empty' },
            (tag.i { className: 'fa fa-spinner' })
          ) if @state.query.length unless @state.people
        )
      ) if @state.editor

      (tag.div {},
        (tag.i { className: 'fa fa-female' })
        "Uman"
      ) unless @state.editor
    )


# Person component
#
Component = React.createClass


  getInitialState: ->
    people: @props.identities
  

  onPersonSelect: (event) ->
    


  render: ->
    (tag.div { className: 'people' },
      (NewPersonComponent { url: @props.collection_url, onPersonSelect: @onPersonSelect })
    )


# Expose
#
cc.react.editor.blocks.People = Component
