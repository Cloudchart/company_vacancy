# Shortcuts
#
tag = React.DOM


# Button
#
Button = (icon, callback) ->
  (tag.button {
    className:  "cloud"
    onClick:    callback
  },
    (tag.i { className: "fa fa-#{icon}" })
  )


#
#
#

Buttons = React.createClass
  

    onNewPersonClick: ->
      identity_form = cc.blueprint.react.forms.Identity({ model: new cc.blueprint.models.Person })
      cc.blueprint.react.modal.show(identity_form, { key: 'identity', title: "New person" })
      
    
    onNewVacancyClick: ->
      identity_form = cc.blueprint.react.forms.Identity({ model: new cc.blueprint.models.Vacancy })
      cc.blueprint.react.modal.show(identity_form, { key: 'identity', title: "New vacancy" })
  

    render: ->
      (tag.section { className: 'buttons' },
        Button('users',     @onNewPersonClick)
        Button('briefcase', @onNewVacancyClick)
      )

#
#
#

_.extend @cc.blueprint.react.IdentityFilter,
  Buttons: Buttons
