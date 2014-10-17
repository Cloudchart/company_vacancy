###
  Used in:

  cloud_blueprint/react/identity_filter
###

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


  getInitialState: ->
    model       = cc.blueprint.models[@props.className].get(@props.key) 

    state       = model.attributes
    state.model = model
    state


  onClick: (event) ->
    return if @state.model.is_synchronizing()
    identity_form = cc.blueprint.react.forms.Identity({ model: @state.model })
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
gather_models = (className, sort_options, query) ->
  instances = cc.blueprint.models[className].instances
  
  _.each query, (part) ->
    instances = _.filter instances, (instance) -> instance.matches(part)
    
  
  _.chain(instances)
    .reject((instance) -> instance.is_deleted())
    .sortBy(sort_options)
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
   
    _.reduce gather_models('Vacancy', 'name', @state.query), (memo, model) ->
      memo.push cc.blueprint.react.Identity({ key: model.uuid, model: model, draggable: true }) ; memo
    , identities

    _.reduce gather_models('Person', ['last_name', 'first_name'], @state.query), (memo, model) ->
      memo.push cc.blueprint.react.Identity({ key: model.uuid, model: model, draggable: true }) ; memo
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
