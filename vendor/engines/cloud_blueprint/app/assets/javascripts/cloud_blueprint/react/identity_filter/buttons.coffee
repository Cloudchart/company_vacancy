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
      identity_form = cc.blueprint.react.forms.Person({ model: new cc.blueprint.models.Person })
      cc.blueprint.react.modal.show(identity_form, { key: 'identity' })
      
    
    onNewVacancyClick: ->
      identity_form = cc.blueprint.react.forms.Vacancy({ model: new cc.blueprint.models.Vacancy })
      cc.blueprint.react.modal.show(identity_form, { key: 'identity' })
  

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
