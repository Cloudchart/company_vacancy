##= require ./node

# Shortcuts
#
tag = React.DOM


# Default colors
#
default_colors = [
  "hsl(  0,  0%, 73%)"
  "hsl( 41, 88%, 68%)"
  "hsl(139, 51%, 59%)"
  "hsl(195, 92%, 67%)"
  "hsl( 20, 92%, 65%)"
  "hsl(247, 41%, 76%)"
  "hsl(347, 93%, 77%)"
]



# Calculations
#
Calculations =
  

  getDimensions: ->
    @__dimensions ||= @getDOMNode().getBoundingClientRect()
  

  getHeight: ->
    @getDimensions().heigth
  

  getWidth: ->
    @getDimensions().width
  
  
  getLayout: ->
    layout = cc.blueprint.layouts.chart(@props.root, @refs)
  
  
  reposition: ->
    layout = @getLayout()

    offset =
      x:  @getWidth() / 2
      y:  @props.top_padding
    
    _.each @refs, (child) ->
      child.setPosition
        left:   layout[child.props.key].x + offset.x
        top:    layout[child.props.key].y + offset.y
    


#
#
#

Chart = React.createClass

  mixins: [
    Calculations
  ]


  getDefaultProps: ->
    colors:       default_colors
    top_padding:  20
  
  
  getInitialState: ->
    refreshed_at: + new Date


  componentDidMount: ->
    @reposition()
    _.each @props.subscribe_on, (message) => Arbiter.subscribe message, @refresh
   
  

  componentDidUpdate: ->
    @__dimensions = null
    @reposition()


  gather_nodes: ->
    _.chain(cc.blueprint.models.Node.instances)
      .reject((instance) -> instance.is_deleted())
      .pluck('uuid')
      .value()


  # Refresh message
  #
  refresh: ->
    @setState
      refreshed_at: + new Date


  render: ->
    nodes = _.map @gather_nodes(), (uuid) =>
      cc.blueprint.react.Blueprint.Node {
        key: uuid
        ref: uuid
        colors: @props.colors
        can_be_edited: @props.can_be_edited
      }

    (tag.section { className: 'chart' },
      (tag.svg {})
      (nodes)
    )


#
#
#

_.extend @cc.blueprint.react.Blueprint,
  Chart: Chart
