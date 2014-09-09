##= require stores/PersonStore

# Shortcuts
#
tag = React.DOM

PersonStore = cc.require('cc.stores.PersonStore')
VacancyStore  = require('stores/vacancy_store')

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
      identity_form = cc.require('cc.blueprint.components.PersonForm')({ model: new PersonStore, company_id: @props.company_id })

      #identity_form = cc.blueprint.react.forms.Identity({ model: new cc.blueprint.models.Person })
      cc.blueprint.react.modal.show(identity_form, { key: 'identity', title: "New person" })
      
    
    onNewVacancyClick: ->
      identity_form = require('cloud_blueprint/components/vacancy_form')({ model: new VacancyStore({ company_id: @props.company_id }) })

      #identity_form = cc.blueprint.react.forms.Identity({ model: new cc.blueprint.models.Vacancy })
      cc.blueprint.react.modal.show(identity_form, { key: 'identity', title: "New vacancy" })
  

    render: ->
      (tag.section { className: 'buttons' },
        Button('male',     @onNewPersonClick)
        Button('briefcase', @onNewVacancyClick)
      )


#
#
#

_.extend @cc.blueprint.react.IdentityFilter,
  Buttons: Buttons
