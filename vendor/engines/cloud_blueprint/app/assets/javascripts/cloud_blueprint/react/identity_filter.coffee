###
  Used in:

  cloud_blueprint/controllers/chart
###

#= require ./identity_filter/identity_list.module
#= require_self
#= require_tree ./identity_filter


# Shortcuts
#
tag = React.DOM


IdentityListComponent = require('cloud_blueprint/react/identity_filter/identity_list')


#
# Toggle
#

Toggle = React.createClass


  componentWillMount: ->
    @directions = ['fa-arrow-left', 'fa-arrow-right']
  
  componentDidUpdate: ->
    @props.callback(@state.direction_index)


  getInitialState: ->
    direction_index: 1
  
  
  onClick: ->
    @setState { direction_index: ~~!@state.direction_index }


  render: ->
    (tag.button {
      className:  'toggle'
      onClick:    @onClick
    },
      tag.i { className: "fa #{@directions[@state.direction_index]}"}
    )


# Animate element slide
#
slide = (element, from, till, duration = 100) ->
  
  start     = null
  length    = till - from
  
  tick  = (timestamp) ->
    start     = timestamp unless start
    progress  = timestamp - start
    delta     = progress / duration
    delta     = 1 if delta > 1

    element.style.left = from + length * delta + 'px'
    
    if progress < duration then requestAnimationFrame(tick) else element.style.left = till + 'px'
  
  requestAnimationFrame(tick)


#
# IdentityFilter
#

IdentityFilter = React.createClass


  componentDidMount: ->
    Arbiter.subscribe 'cc:blueprint:identity-filter/show', @show
    Arbiter.subscribe 'cc:blueprint:identity-filter/hide', @hide
  

  componentWillUnmout: ->
    Arbiter.unsubscribe 'cc:blueprint:identity-filter/show', @show
    Arbiter.unsubscribe 'cc:blueprint:identity-filter/hide', @hide
  
  
  show: ->
    element = @getDOMNode()
    bounds  = element.getBoundingClientRect()
    slide(element, bounds.left, 0, 0)
  

  hide: ->
    element = @getDOMNode()
    bounds  = element.getBoundingClientRect()
    slide(element, bounds.left, bounds.width * (@refs['toggle'].state.direction_index * -1), 0)


  onToggle: (direction_index) ->
    element = @getDOMNode()
    bounds  = element.getBoundingClientRect()
    slide(element, bounds.left, bounds.width * (direction_index  * -1))


  onSearchChange: (value) ->
    query = _.reject value.trim().replace(/\s+/, ' ').toLowerCase().split(' '), (part) -> part.length == 0
    @refs.list.search(query)
    

  render: ->
    (tag.aside { className: 'identity-filter' },
      Toggle({ ref: 'toggle', callback: @onToggle })

      cc.blueprint.react.IdentityFilter.Search({ ref: 'search', callback: @onSearchChange })

      #IdentityListComponent({
      #  ref:          'list'
      #})
      cc.blueprint.react.IdentityFilter.IdentityList({ ref: 'list', subscribe_on: @props.subscribe_on })

      cc.blueprint.react.IdentityFilter.Buttons({ ref: 'buttons', company_id: @props.company_id })
    )

#
#
#

_.extend @cc.blueprint.react,
  IdentityFilter: IdentityFilter
