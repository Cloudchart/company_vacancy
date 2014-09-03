##= require react_components/company/header
##= require react_components/editor

# Imports
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
    _.extend({ owner: 'company' }, @props)

# Exports
#
cc.module('react/company').exports = MainComponent
