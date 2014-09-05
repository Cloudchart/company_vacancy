##= require react_components/company/header
##= require react_components/editor
##= require react_components/company/settings
##= require react_components/company/burn_rate

# Imports
#
tag                   = cc.require('react/dom')
HeaderComponent       = cc.require('react/company/header')
EditorComponent       = cc.require('react/editor')
SettingsComponent     = cc.require('react/company/settings')
BurnRateComponent     = cc.require('react/company/burn_rate')

# Company Main component
#
MainComponent = React.createClass

  render: ->
    (tag.article { className: 'company' },

      (HeaderComponent @extendedPropsForHeader())
      @contentToggler()[@state.toggle_value]

    )

  getInitialState: ->
    toggle_value: 'editor'

  extendedPropsForHeader: ->
    _.extend({ onChange: @onHeaderNavChange, toggle_value: @state.toggle_value }, @props)

  extendedPropsForEditor: ->
    _.extend({ owner: 'company' }, @props)

  onHeaderNavChange: (value) ->
    @setState({ toggle_value: value })

  contentToggler: ->
    {
      editor: (EditorComponent @extendedPropsForEditor())
      settings: (SettingsComponent @props)
      burn_rate: (BurnRateComponent @props)
    }

# Exports
#
cc.module('react/company').exports = MainComponent
