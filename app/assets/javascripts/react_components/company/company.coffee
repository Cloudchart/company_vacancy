##= require react_components/company/header
##= require react_components/editor
##= require react_components/company/settings
##= require react_components/company/burn_rate
##= require stores/PersonStore
##= require constants.module
##= require utils/event_emitter.module
##= require stores/company_store.module
##= require stores/tag_store.module

# Imports
#
tag                   = cc.require('react/dom')
HeaderComponent       = cc.require('react/company/header')
EditorComponent       = cc.require('react/editor')
SettingsComponent     = cc.require('react/company/settings')
BurnRateComponent     = cc.require('react/company/burn_rate')
PersonStore           = cc.require('cc.stores.PersonStore')
CompanyStore          = require('stores/company_store')
TagStore              = require('stores/tag_store')

# Company Main component
#
MainComponent = React.createClass

  render: ->
    if @state.company
      (tag.article { className: 'company' },
        (HeaderComponent @extendedPropsForHeader())
        @contentToggler()[@state.toggle_value]
      )
    else
      (tag.noscript null)

  getInitialState: ->
    company: CompanyStore.get(@props.key)
    all_tags: TagStore.all()
    people: PersonStore.all()
    toggle_value: 'editor'

  componentDidMount: ->
    PersonStore.on('change', @onPeresonStoreChange)
    CompanyStore.on('change', @onCompanyStoreChange)
    TagStore.on('change', @onTagStoreChange)

  componentWillUnmount: ->
    PersonStore.off('change', @onPeresonStoreChange)
    CompanyStore.off('change', @onCompanyStoreChange)
    TagStore.off('change', @onTagStoreChange)

  onPeresonStoreChange: ->
    @setState({ people: PersonStore.all() })

  onCompanyStoreChange: ->
    @setState({ company: CompanyStore.get(@props.key) })

  onTagStoreChange: ->
    @setState({ all_tags: TagStore.all() })

  getStateFromStores: ->
    company: CompanyStore.get(@props.key)
    all_tags: TagStore.all()
    people: PersonStore.all()

  extendedPropsForHeader: ->
    _.extend({ onChange: @onHeaderNavChange, toggle_value: @state.toggle_value }, @state.company)

  extendedPropsForEditor: ->
    _.extend({ owner: 'company' }, @state.company) # TODO: need to pass people and vacancies as props...

  extendedPropsForSettings: ->
    _.extend({ people: @state.people, all_tags: @state.all_tags }, @state.company)

  onHeaderNavChange: (value) ->
    @setState({ toggle_value: value })
  
  refreshStateFromStores: ->
    @setState @getStateFromStores()

  contentToggler: ->
    {
      editor: (EditorComponent @extendedPropsForEditor())
      settings: (SettingsComponent @extendedPropsForSettings())
      burn_rate: (BurnRateComponent { 
        # TODO: new store for burn rate chart
        charts: @state.company.burn_rate_charts
        established_on: @state.company.established_on
      })
    }

# Exports
#
cc.module('react/company').exports = MainComponent
