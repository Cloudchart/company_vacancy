##= require react_components/company/header
##= require react_components/editor
##= require react_components/company/settings
##= require react_components/company/burn_rate
##= require stores/PersonStore

# Imports
#
tag                   = cc.require('react/dom')
HeaderComponent       = cc.require('react/company/header')
EditorComponent       = cc.require('react/editor')
SettingsComponent     = cc.require('react/company/settings')
BurnRateComponent     = cc.require('react/company/burn_rate')
PersonStore           = cc.require('cc.stores.PersonStore')

# Company Main component
#
MainComponent = React.createClass

  render: ->
    (tag.article { className: 'company' },

      (HeaderComponent @extendedPropsForHeader())
      @contentToggler()[@state.toggle_value] if @state.people_loaded # TODO: add vacancies and other dependencies

    )

  getInitialState: ->
    people_loaded: false
    toggle_value: 'burn_rate'

  componentDidMount: ->
    PersonStore.on('change', @onPeresonStoreChange)

  componentWillUnmount: ->
    PersonStore.off('change', @onPeresonStoreChange)

  onPeresonStoreChange: ->
    @setState({ people_loaded: true })

  extendedPropsForHeader: ->
    _.extend({ onChange: @onHeaderNavChange, toggle_value: @state.toggle_value }, @props)

  extendedPropsForEditor: ->
    _.extend({ owner: 'company' }, @props) # TODO: need to pass people and vacancies as props...

  onHeaderNavChange: (value) ->
    @setState({ toggle_value: value })

  contentToggler: ->
    {
      editor: (EditorComponent @extendedPropsForEditor())
      settings: (SettingsComponent @props)
      burn_rate: (BurnRateComponent { 
        # people: PersonStore.all()
        charts_for_select: @props.charts_for_select
        charts: @props.charts
      })
    }

# Exports
#
cc.module('react/company').exports = MainComponent
