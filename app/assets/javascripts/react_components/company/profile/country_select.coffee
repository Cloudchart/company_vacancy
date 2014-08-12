tag = React.DOM

Component = React.createClass
  emptyCountry: ->
    (tag.option {
      key: 'empty'
    }, 'Country...')


  items: ->
    items = @props.countries.map (pair) ->
      [name, code] = pair

      (tag.option {
        key:    code
        value:  code
      }, name)
    
    items.unshift(@emptyCountry()) unless @state.value
    
    items


  onChange: (event) ->
    @setState
      value: event.target.value

  
  getDefaultProps: ->
    countries: cc.require('countries')


  getInitialState: ->
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
