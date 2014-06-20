##= require ./node_form

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
# Render person
#
Person = (model) ->
  (tag.li { className: 'person' },
    (Icon('users'))
    (tag.h2 {},
      (tag.span { className: 'first-name light' }, model.first_name)
      " "
      (tag.span { className: 'last-name'  }, model.last_name)
    )
    (tag.p {}, model.occupation)
  )


#
# Render vacancy
#
Vacancy = (model) ->
  (tag.li { className: 'vacancy' },
    (Icon('briefcase'))
  )
  

#
#
renders = 
  'Person':   Person
  'Vacancy':  Vacancy
  

#
#
#

Identity = React.createClass

  render: ->
    renders[@props.model.constructor.className](@props.model)

#
#
#

_.extend @cc.blueprint.react.forms.Node,
  Identity: Identity
