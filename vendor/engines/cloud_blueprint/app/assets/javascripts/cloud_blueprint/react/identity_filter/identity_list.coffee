# Shortcuts
#

tag = React.DOM


#
# Icon
#
Icon = (name) ->
  (tag.aside { className: 'icon' },
    (tag.i { className: "fa fa-#{name}" })
  )


#
# Vacancy
#
Vacancy = React.createClass

  getInitialState: ->
    name: 'Name'
  
  
  onClick: (event) ->
    alert 'edit vacancy'
  
  
  render: ->
    (tag.li {
      onClick: @onClick
    },
      Icon('briefcase')
      (tag.h2 {}, @state.name)
      (tag.p {}, 'Vacancy')
    )

#
# Person
#

Person = React.createClass

  
  getDefaultProps: ->
    model: cc.blueprint.models.Person.get(@props.key)


  getInitialState: ->
    @props.model.attributes


  renderForm: (container) ->
    React.renderComponent(cc.blueprint.react.forms.Person({ model: @props.model }), container)
  

  hideForm: (container) ->
    React.unmountComponentAtNode(container)


  onClick: (event) ->
    return if @props.model.is_synchronizing()

    cc.ui.modal null,
      after_show:   @renderForm
      before_close: @hideForm
  
  
  render: ->
    (tag.li {
      onClick: @onClick
    },
      (Icon('users'))
      (tag.h2 { key: 'name' },
        (tag.span { className: 'first-name light' }, @state.first_name)
        " "
        (tag.span { className: 'last-name'  }, @state.last_name)
      )
      (tag.p {}, @state.occupation)
    )


# Gather models uuids
#
gather_models_uuids = (className, sort_options) ->
  _.chain(cc.blueprint.models[className].instances)
    .reject((instance) -> instance.is_deleted())
    .sortBy(sort_options)
    .pluck('uuid')
    .value()


#
#
#

IdentityList = React.createClass

  
  componentDidMount: ->
    Arbiter.subscribe @props.subscribe_on, @refresh


  getInitialState: ->
    vacancies:  []
    people:     []

  
  refresh: ->
    @setState
      vacancies:  gather_models_uuids('Vacancy', 'name')
      people:     gather_models_uuids('Person', ['last_name', 'first_name'])


  render: ->
    identities = []
    

    # Gather vacancy components
    _.reduce @state.vacancies, (memo, uuid) ->
      memo.push Vacancy({ key: uuid, ref: uuid }) ; memo
    , identities
    
    # Gather person components
    _.reduce @state.people, (memo, uuid) ->
      memo.push Person({ key: uuid, ref: uuid }) ; memo
    , identities


    (tag.ul { className: 'identity-list' }, identities)


#
#
#

_.extend @cc.blueprint.react.IdentityFilter,
  IdentityList: IdentityList
