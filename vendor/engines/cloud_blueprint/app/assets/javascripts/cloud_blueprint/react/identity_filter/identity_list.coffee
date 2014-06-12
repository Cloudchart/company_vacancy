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
# Lock
#
Lock = (model) ->
  (tag.i { className: 'fa fa-lock lock' }) if model.is_synchronizing()


#
#
#
IdentityCommons =

  getDefaultProps: ->
    model: cc.blueprint.models[@props.className].get(@props.key)


  getInitialState: ->
    @props.model.attributes


  renderForm: (container) ->
    React.renderComponent(cc.blueprint.react.forms[@props.className]({ model: @props.model }), container)
  

  hideForm: (container) ->
    React.unmountComponentAtNode(container)


  onClick: (event) ->
    return if @props.model.is_synchronizing()

    cc.ui.modal null,
      after_show:   @renderForm
      before_close: @hideForm
  

  onDragStart: (event) ->
    event.dataTransfer.effectAllowed = 'link'
    event.dataTransfer.setData('identity', JSON.stringify({ className: @props.className, uuid: @props.key }))


#
# Vacancy
#
Vacancy = React.createClass


  mixins: [
    IdentityCommons
  ]
  
  
  render: ->
    (tag.li {
      onClick:      @onClick
      draggable:    true
      onDragStart:  @onDragStart
    },
      (Icon('briefcase'))
      (tag.h2 {}, @state.name)
      (tag.p {}, 'Vacancy')
      (Lock @props.model)
    )

#
# Person
#

Person = React.createClass

  mixins: [
    IdentityCommons
  ]

  render: ->
    (tag.li {
      onClick:      @onClick
      draggable:    true
      onDragStart:  @onDragStart
    },
      (Icon('users'))
      (tag.h2 {},
        (tag.span { className: 'first-name light' }, @state.first_name)
        " "
        (tag.span { className: 'last-name'  }, @state.last_name)
      )
      (tag.p {}, @state.occupation)
      (Lock @props.model)
    )


# Gather models uuids
#
gather_models_uuids = (className, sort_options, query) ->
  instances = cc.blueprint.models[className].instances
  
  _.each query, (part) ->
    instances = _.filter instances, (instance) -> instance.matches(part)
    
  
  _.chain(instances)
    .reject((instance) -> instance.is_deleted())
    .sortBy(sort_options)
    .pluck('uuid')
    .value()


#
#
#

IdentityList = React.createClass

  
  componentDidMount: ->
    _.each @props.subscribe_on, (message) => Arbiter.subscribe message, @refresh


  getInitialState: ->
    query:        []
    refreshed_at: + new Date


  gatherIdentities: ->
    identities = []
   
    # Gather vacancy components
    _.reduce gather_models_uuids('Vacancy', 'name', @state.query), (memo, uuid) ->
      memo.push Vacancy({ key: uuid, ref: uuid, className: 'Vacancy' }) ; memo
    , identities
    
    # Gather person components
    _.reduce gather_models_uuids('Person', ['last_name', 'first_name'], @state.query), (memo, uuid) ->
      memo.push Person({ key: uuid, ref: uuid, className: 'Person' }) ; memo
    , identities
    
    identities
  
  
  search: (value) ->
    @setState
      query: value
  
  
  refresh: ->
    @setState
      refreshed_at: + new Date


  render: ->
    (tag.ul { className: 'identity-list' }, @gatherIdentities())


#
#
#

_.extend @cc.blueprint.react.IdentityFilter,
  IdentityList: IdentityList