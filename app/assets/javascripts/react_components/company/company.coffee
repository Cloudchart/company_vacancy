##= require react_components/company/header
##= require react_components/editor
##= require react_components/company/settings
##= require react_components/company/burn_rate
##= require stores/PersonStore
##= require constants.module
##= require utils/event_emitter.module
##= require stores/company_store.module

# Imports
#
tag                   = cc.require('react/dom')
HeaderComponent       = cc.require('react/company/header')
EditorComponent       = cc.require('react/editor')
SettingsComponent     = cc.require('react/company/settings')
BurnRateComponent     = cc.require('react/company/burn_rate')
PersonStore           = cc.require('cc.stores.PersonStore')
CompanyStore          = require('stores/company_store')


# Get State From Stores
#
getStateFromStores = (key) ->
  company: CompanyStore.get(key)
  

# Company Main component
#
MainComponent = React.createClass

  render: ->
    if @state.company
      (tag.article { className: 'company' },
        (HeaderComponent @extendedPropsForHeader())
        @contentToggler()[@state.toggle_value] if @state.people_loaded # TODO: add vacancies and other dependencies
      )
    else
      (tag.noscript null)


  getInitialState: ->
    state = getStateFromStores(@props.key)
    state.people_loaded = false
    state.toggle_value  = 'editor'
    state


  componentDidMount: ->
    PersonStore.on('change', @onPeresonStoreChange)
    CompanyStore.on('change', @refreshStateFromStores)


  componentWillUnmount: ->
    PersonStore.off('change', @onPeresonStoreChange)
    CompanyStore.off('change', @refreshStateFromStores)


  onPeresonStoreChange: ->
    @setState({ people_loaded: true })


  extendedPropsForHeader: ->
    _.extend({ onChange: @onHeaderNavChange, toggle_value: @state.toggle_value }, @state.company)


  extendedPropsForEditor: ->
    _.extend({ owner: 'company' }, @state.company) # TODO: need to pass people and vacancies as props...


  onHeaderNavChange: (value) ->
    @setState({ toggle_value: value })
  
  
  refreshStateFromStores: ->
    @setState getStateFromStores(@props.key)


  contentToggler: ->
    {
      editor: (EditorComponent @extendedPropsForEditor())
      settings: (SettingsComponent @state.company)
      burn_rate: (BurnRateComponent { 
        # TODO: new store for chart people
        # people: PersonStore.all()
        charts_for_select: @state.company.charts_for_select
        charts: @state.company.charts
        established_on: @state.company.established_on
      })
    }

# Exports
#
cc.module('react/company').exports = MainComponent
