##= require colors
##= require ./person
##= require ./vacancy

# Imports
#
tag               = React.DOM
defaultNodeColor  = 'hsl(0, 0%, 73%)'
colors            = cc.require('colors') ; colors.unshift(defaultNodeColor)
PersonComponent   = cc.require('blueprint/react/chart-preview/person')
VacancyComponent  = cc.require('blueprint/react/chart-preview/vacancy')


# Filter identities by type
#
filterIdentitiesByIdentityType = (identities, identity_type) ->
  identities.filter((identity) -> identity.identity_type == identity_type).map((identity) -> identity.identity)


# Main Component
#
MainComponent = React.createClass


  getUUID: ->
    @props.uuid
  

  getParentId: ->
    @props.parent_id
  
  
  getKnots: ->
    @props.knots
  
  
  getPosition: ->
    @props.position
  
  
  setActualDimensions: ->
    @getDOMNode().style.minWidth = (@props.children_count + 1) * @props.space_per_child + 'px'


  resetDimensions: ->
    @__dimenstion = null


  getDimensions: ->
    @__dimensions ||= @getDOMNode().getBoundingClientRect()
  
  
  getWidth: ->
    @getDimensions().width
  
  
  getHeight: ->
    @getDimensions().height
  
  
  position: (position) ->
    node = @getDOMNode()

    node.style.left = position.x  - @getWidth()   / 2 + 'px'
    node.style.top  = position.y  - @getHeight()  / 2 + 'px'


  identities: ->
    people    = filterIdentitiesByIdentityType(@props.identities, 'Person')
    vacancies = filterIdentitiesByIdentityType(@props.identities, 'Vacancy')
    
    [
      people.map (person_props) ->
        person_props.key = person_props.uuid
        PersonComponent(person_props)

      vacancies.map (vacancy_props) ->
        vacancy_props.key = vacancy_props.uuid
        VacancyComponent(vacancy_props)
    ]
  
  
  onClick: ->
    window.location.href = @props.url if @props.url


  componentDidMount: ->
    @setActualDimensions()
    @resetDimensions()
  

  componentDidUpdate: ->
    @setActualDimensions()
    @resetDimensions()


  getDefaultProps: ->
    space_per_child: 10


  render: ->
    (tag.div {
      className:  'node'
      onClick:    @onClick
      style:
        backgroundColor: colors[@props.color_index % colors.length]
    },
      (tag.header {}, @props.title) if @props.title
      (tag.ul {}, @identities())
    )


# Exports
#
cc.module('blueprint/react/chart-preview/node').exports = MainComponent
