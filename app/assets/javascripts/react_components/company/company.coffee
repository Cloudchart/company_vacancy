##= require react_components/company/header
##= require react_components/editor

#
#
tag                   = cc.require('react/dom')
HeaderComponent       = cc.require('react/company/header')
EditorComponent       = cc.require('react/editor')


# Company Main component
#
MainComponent = React.createClass

  render: ->
    (tag.article { className: 'company' },

      (HeaderComponent @props)
      (EditorComponent @extendedProps())

    )

  extendedProps: ->
    $.extend({ owner: 'company' }, @props)

# Expose
#
cc.module('react/company').exports = MainComponent
