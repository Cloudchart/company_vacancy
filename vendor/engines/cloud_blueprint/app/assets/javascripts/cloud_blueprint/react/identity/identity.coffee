# Shotcuts
#

tag = React.DOM


#
# Commons
#


#
# Person
#

# Person icon background color
#
PersonIconBackgroundColors = [
  "hsl( 41, 88%, 68%)"
  "hsl(139, 51%, 59%)"
  "hsl(195, 92%, 67%)"
  "hsl( 20, 92%, 65%)"
  "hsl(247, 41%, 76%)"
]

# Person icon
#

PersonIcon = (model) ->
  code = _.reduce ['first_name', 'last_name'], (memo, name) ->
    memo += model[name].charCodeAt(0) if model[name] ; memo
  , 0

  (tag.aside {
    key: 'icon'
    style:
      backgroundColor: PersonIconBackgroundColors[code % PersonIconBackgroundColors.length]
  },
    (tag.span {},
      model.first_name.charAt(0) if model.first_name
      model.last_name.charAt(0) if model.last_name
    )
    
  )


# Person render
#

PersonRender = (self) ->
  [
    (PersonIcon(self.props.model))
    (tag.section { key: 'description' },
      (tag.h2 {},
        self.props.model.first_name
        " "
        self.props.model.last_name
      )
      (tag.p {}, self.props.model.occupation) if self.props.model.occupation
    )
  ]


#
# Vacancy
#


# Vacancy icon
#

VacancyIcon = (model) ->
  (tag.aside {
    key: 'icon'
  },
    (tag.i { className: 'fa fa-briefcase' })
  )


# Vacancy render
#

VacancyRender = (self) ->
  [
    (VacancyIcon(self.props.model))
    (tag.section { key: 'description' },
      (tag.h2 {}, self.props.model.name)
      (tag.p  {}, "Vacancy")
    )
  ]


#
# Identity component
#

IdentityComponent = React.createClass

  onClick: (event) ->
    event.preventDefault()
    
    return if @props.model.is_synchronizing()
    
    form_options            = {}
    form_options.model      = @props.model
    form_options.node_uuid  = @props.node.uuid if @props.node

    form = cc.blueprint.react.forms.Identity(form_options)

    cc.blueprint.react.modal.show form,
      key:    "identity",
      title:  "Edit #{@props.model.constructor.className.toLowerCase()}"
    

  
  getDefaultProps: ->
    draggable:  false
    renders:
      Person:   PersonRender
      Vacancy:  VacancyRender


  render: ->
    (tag.li {
      className:  "blueprint-identity #{@props.model.constructor.className.toLowerCase()}"
      onClick:    @onClick

      'data-id':          @props.model.uuid
      'data-class-name':  @props.model.constructor.className
      'data-behaviour':   'draggable' if @props.draggable == true
    },
      @props.renders[@props.model.constructor.className](@)
    )
    


# Identity components availability
#
_.extend IdentityComponent,
  PersonIconBackgroundColors:   PersonIconBackgroundColors
  PersonIcon:                   PersonIcon
  VacancyIcon:                  VacancyIcon


# Identity component availability
#

_.extend @cc.blueprint.react,
  Identity: IdentityComponent
