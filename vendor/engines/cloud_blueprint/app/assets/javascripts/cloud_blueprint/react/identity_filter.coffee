#= require_self
#= require_tree ./identity_filter


# Shortcuts
#
tag = React.DOM


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
slide = (element, from, till) ->
  
  duration  = 100
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


  onToggle: (direction_index) ->
    element = @getDOMNode()
    bounds  = element.getBoundingClientRect()
    slide(element, bounds.left, bounds.width * (direction_index  * -1))


  onSearchChange: (value) ->
    @refs.list.search(_.reject value.trim().replace(/\s+/, ' ').toLowerCase().split(' '), (part) -> part.length == 0)
    

  render: ->
    (tag.aside { className: 'identity-filter' },
      Toggle({ callback: @onToggle })
      cc.blueprint.react.IdentityFilter.Search({ ref: 'search', callback: @onSearchChange })
      cc.blueprint.react.IdentityFilter.IdentityList({ ref: 'list', subscribe_on: @props.subscribe_on })
      cc.blueprint.react.IdentityFilter.Buttons({ ref: 'buttons' })
    )

#
#
#

_.extend @cc.blueprint.react,
  IdentityFilter: IdentityFilter
