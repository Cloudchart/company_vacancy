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
Person = (model, clickHandler) ->
  (tag.li { className: 'person', onClick: clickHandler },
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
Vacancy = (model, clickHandler) ->
  (tag.li { className: 'vacancy', onClick: clickHandler },
    (Icon('briefcase'))
    (tag.h2 {},
      (tag.span { className: 'name light' }, model.name)
    )
    (tag.p {}, 'Vacancy')
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

  onClick: (event) ->
    return if @props.model.is_synchronizing()
    identity_form = cc.blueprint.react.forms.Identity({ model: @props.model, node_uuid: @props.node.uuid })
    cc.blueprint.react.modal.show(identity_form, { key: 'identity', title: "Edit #{@props.model.constructor.className.toLowerCase()}" })


  render: ->
    renders[@props.model.constructor.className](@props.model, @onClick)

#
#
#

_.extend @cc.blueprint.react.forms.Node,
  Identity: Identity
