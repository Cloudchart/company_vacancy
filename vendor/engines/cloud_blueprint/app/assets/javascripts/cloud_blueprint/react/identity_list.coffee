@cc                   ||= {}
@cc.blueprint         ||= {}
@cc.blueprint.react   ||= {}

#
#
#


# Destructure
#
{ aside, div, h2, i, li, p, span, ul } = React.DOM


# Models
#
models =
  Vacancy:  cc.blueprint.models.Vacancy
  Person:   cc.blueprint.models.Person


# Icon
#
icon_component = (name) ->
  (aside { key: 'icon', className: 'icon' },
    (i { className: "fa fa-#{name}" })
  )


# Commons
#
commons =
  
  getInitialState: ->
    {}
  

  refresh: ->
    @setState @model.attributes
  

  componentWillMount: ->
    @model = @props.modelClass.get(@props.key)
  

  componentDidMount: ->
    @refresh()
  

  handleClick: (event) ->
    model = @model

    cc.ui.modal '',

      after_show: (container) ->
        React.renderComponent(cc.blueprint.react.person_form({ model: model }), container)

      before_close: (container) ->
        React.unmountComponentAtNode(container)
        
  

  handleDragStart: (event) ->
    event.dataTransfer.setData('text', JSON.stringify({ uuid: @props.key, className: @model.className }))


# Vacancy
#
vacancy = React.createClass

  mixins: [commons]
  
  
  displayName: 'Vacancy'
  

  render: ->
    (li {
      className:          'vacancy'
      'data-id':          @props.key
      'data-class-name':  @model.className
      onClick:            @handleClick
    }, [
      (icon_component 'briefcase')
      (h2 null, @state.name)
      (p null, 'Vacancy')
    ])


# Person
#
person = React.createClass
  
  mixins: [commons]

  displayName: 'Person'

  render: ->
    (li {
      className:          'person'
      draggable:          true
      'data-class-name':  @model.className
      onClick:            @handleClick
      onDragStart:        @handleDragStart
      onDragEnd:          @handleDragEnd
    }, [
      (icon_component 'users')
      (h2 { key: 'name' }, [
        (span { key: 'first-name', className: 'first_name light' },  @state.first_name)
        (span { key: 'last-name', className: 'last_name' },         @state.last_name)
      ])
      (p { key: 'occupation' }, @state.occupation)
    ])


# Identity list
#

identity_list = React.createClass


  getInitialState: ->
    vacancies:  []
    people:     []
  

  refresh: ->
    @setState
      vacancies:  _.chain(models.Vacancy.instances).sortBy('name').pluck('uuid').value()
      people:     _.chain(models.Person.instances).sortBy(['last_name', 'first_name']).pluck('uuid').value()

    _.invoke @refs, 'refresh'


  componentDidMount: ->
    @refresh()


  render: ->
    @vacancies   = _.map @state.vacancies, (uuid) -> vacancy({ key: uuid, modelClass: models.Vacancy, ref: uuid })
    @people      = _.map @state.people, (uuid) -> person({ key: uuid, modelClass: models.Person, ref: uuid })
    
    (ul null, [@vacancies, @people])

#
#
#

_.extend @cc.blueprint.react,
  identity_list: identity_list
