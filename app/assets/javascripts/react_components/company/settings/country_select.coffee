##= require stores/CountryStore

# Imports
#
#
tag = React.DOM

CountryStore = cc.require('cc.stores.CountryStore')


# Functions
#
getStateFromStores = ->
  countries: _.sortBy CountryStore.all(), (country) -> country.sortValue()


# Main Component
#
Component = React.createClass
  emptyCountry: ->
    (tag.option {
      key: 'empty'
    }, 'Country...')


  items: ->
    items = @state.countries.map (country) ->
      (tag.option {
        key:    country.to_param()
        value:  country.to_param()
      }, country.attr('name'))
    
    items.unshift(@emptyCountry()) unless @state.value
    
    items


  onChange: (event) ->
    @setState
      value: event.target.value
    
  
  onStoresChange: ->
    @setState getStateFromStores()
  
  
  componentDidMount: ->
    CountryStore.on('change', @onStoresChange)
  
  
  componentWillUnmout: ->
    CountryStore.off('change', @onStoresChange)

  
  getInitialState: ->
    _.extend {}, getStateFromStores(),
      value: @props.value
  
  
  componentDidUpdate: (prevProps, prevState) ->
    @props.onChange({ target: { value: @state.value }}) if @props.onChange instanceof Function and @state.value != prevState.value


  render: ->
    (tag.select {
      className:  'country-list'
      value:      @state.value
      onChange:   @onChange
    }, @items())
 

# Exports
cc.module('react/company/country_select').exports = Component
