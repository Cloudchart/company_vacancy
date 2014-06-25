# Shortcuts
#

tag = React.DOM


# Default colors
#
default_colors = [
  "hsl( 41, 88%, 68%)"
  "hsl(139, 51%, 59%)"
  "hsl(195, 92%, 67%)"
  "hsl( 20, 92%, 65%)"
  "hsl(247, 41%, 76%)"
]


#
# Icon
#
Icon = (name) ->
  (tag.aside { className: 'icon' },
    (tag.i { className: "fa fa-#{name}" })
  )

#
# Named Icon
#
NamedIcon = (letters) ->
  letters     = letters.toUpperCase()
  color_index = _.reduce letters, ((memo, letter) -> memo += letter.charCodeAt(0)), 0
  color       = default_colors[color_index % default_colors.length]
  
  (tag.aside {
    className: 'icon'
    style:
      backgroundColor: color
  },
    (tag.span {}, letters)
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


  onClick: (event) ->
    return if @props.model.is_synchronizing()
    identity_form = cc.blueprint.react.forms.Identity({ model: @props.model })
    cc.blueprint.react.modal.show(identity_form, { key: 'identity', title: "Edit #{@props.model.constructor.className.toLowerCase()}" })


#
# Vacancy
#
Vacancy = React.createClass


  mixins: [
    IdentityCommons
  ]
  
  
  render: ->
    (tag.li {
      onClick:            @onClick
      className:          @props.className.toLowerCase()
      'data-behaviour':   'draggable'
      'data-id':          @props.key
      'data-class-name':  @props.className
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
      onClick:            @onClick
      'data-behaviour':   'draggable'
      'data-id':          @props.key
      'data-class-name':  @props.className
    },
      (NamedIcon(@state.first_name[0] + '' + @state.last_name[0]))
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
