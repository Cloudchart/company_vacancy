###
  Used in:

  cloud_blueprint/controllers/chart
###

#
# Shortcuts
#
tag = React.DOM


#
# Spinner
#

Spinner = ->
  (tag.div { className: 'lock' },
    (tag.i { className: 'fa fa-refresh fa-spin' })
  )


#
#
#

_.extend @cc.blueprint.react,
  Spinner:

    show: ->
      cc.ui.modal null,

        locked: true

        after_show:   (container) ->
          React.renderComponent(Spinner(), container)
          
        before_close: (container) ->
          React.unmountComponentAtNode(container)


    hide: ->
      cc.ui.modal.close()
