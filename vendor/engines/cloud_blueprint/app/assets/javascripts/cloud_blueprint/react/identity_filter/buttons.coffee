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
      @form = cc.blueprint.react.forms.Person({ model: new cc.blueprint.models.Person })
      cc.ui.modal null,
        after_show:   @renderForm
        before_close: @hideForm
      
    
    renderForm: (container) ->
      React.renderComponent(@form, container)
    
    
    hideForm: (container) ->
      React.unmountComponentAtNode(container)
    

    onNewVacancyClick: ->
      alert 'create vacancy'
  

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
