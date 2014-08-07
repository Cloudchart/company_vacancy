##= require module

# Imports
#
tag = cc.require('react/dom')
profile_attributes = ['country', 'industry', 'is_listed', 'short_name']

# Short Url Component
# 
ShortUrlComponent = React.createClass

  render: ->
    (tag.fieldset {},
      (tag.label { htmlFor: 'short_url' }, 'Short URL')

      (tag.input {
        id: 'short_url'
        name: 'short_url'
        placeholder: 'Type company name'
        onKeyUp: @onKeyUp
        onChange: @onChange
        # onFocus: @onFocus
        value: @state.value
        className: 'error' if @state.error
      },
        (tag.button {},
          (tag.i { className: 'fa fa-pencil' })
        )
      )
    )

  getInitialState: ->
    value: @props.value
    error: @props.error

  onKeyUp: (event) ->
    switch event.key
      when 'Enter'
        # console.log 'Enter'
        @props.onChange
          target:
            value: @state.value
      # when 'Escape'
        # console.log 'Escape'

  onChange: (event) ->
    @setState
      value: event.target.value

  onFocus: (event) ->
    @setState
      error: false

# Country Select Component
#
CountrySelectComponent = React.createClass


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
  


# Industry Select Component
#
IndustrySelectComponent = React.createClass


  emptyIndustry: ->
    (tag.option {
      key: 'empty'
    }, 'Industry...')


  items: ->
    roots = _.sortBy @props.industries.filter((industry) -> !industry.parent_id), 'name'

    items = roots.map (industry) =>

      children  = _.sortBy @props.industries.filter((child) -> child.parent_id == industry.uuid), 'name'

      [
        (tag.option {
          key:    industry.uuid
          value:  industry.uuid
        }, industry.name),

        children.map (child) ->
          (tag.option {
            key:    child.id
            value:  child.uuid
          }, "— #{child.name}")
      ]
    
    items.unshift(@emptyIndustry()) unless @state.value

    items
  
  
  onChange: (event) ->
    @setState
      value: event.target.value


  getDefaultProps: ->
    industries: cc.require('industries')


  getInitialState: ->
    value: @props.value
  
  
  componentDidUpdate: (prevProps, prevState) ->
    @props.onChange({ target: { value: @state.value }}) if @props.onChange instanceof Function and @state.value != prevState.value


  render: ->
    (tag.select {
      className: 'industry-select'
      value:      @state.value
      onChange:   @onChange
    }, @items())



# Main Component
#
MainComponent = React.createClass


  onSaveDone: (json) ->
    @setState
      country:        json.country
      industry:       json.industry_ids[0]
      is_listed:      json.is_listed
      short_name:     json.short_name
      synchronizing:  false
    
  
  onSaveFail: ->
    console.warn "Fail: Company profile save."

    @setState
      error: true
      synchronizing:  false


  save: ->
    data = profile_attributes.reduce ((memo, name) => memo.append("company[#{name}]", @state[name]) if @state[name]?; memo), new FormData
    
    @setState
      synchronizing: true
    
    $.ajax
      url:        @props.url
      data:       data
      type:       'PUT'
      dataType:   'json'
      contentType:  false
      processData:  false

    .done @onSaveDone
    .fail @onSaveFail
  
  
  toggleListing: ->
    @setState
      is_listed: !@state.is_listed

  
  onCountryChange: (event) ->
    @setState
      country: event.target.value
  
  
  onIndustryChange: (event) ->
    @setState
      industry: event.target.value

  onShortNameChange: (event) ->
    @setState
      short_name: event.target.value  
  
  getInitialState: ->
    error: false
    synchronizing: false

    country:    @props.country
    industry:   @props.industry_ids[0]
    is_listed:  @props.is_listed
    short_name: @props.short_name
  
  
  componentDidUpdate: (prevProps, prevState) ->
    @save() if profile_attributes.some((name) => @state[name] isnt prevState[name])


  render: ->
    (tag.section {
      className: 'company-profile'
    },
      (tag.header {}, 'Company Profile')
      
      (tag.div { className: 'section-block' },

        (ShortUrlComponent {
          value: @state.short_name
          onChange: @onShortNameChange
          error: @state.error
        })

        'Industry'
        (IndustrySelectComponent {
          value:      @state.industry
          onChange:   @onIndustryChange
        })
        
        'Region'
        (CountrySelectComponent {
          value:      @state.country
          onChange:   @onCountryChange
        })

        (tag.p {}, 'To become listed on the CloudChart company search, please fill out your industry and your region.')

        (tag.footer {},
          'Your company is'

          (tag.button {
            className:  'orgpad'
            disabled:   !(@state.country and @state.industry)
            onClick:    @toggleListing
          }, 'Unlisted') unless @state.is_listed

          (tag.button {
            className: 'orgpad'
            onClick:    @toggleListing
          }, 'Listed') if @state.is_listed

        )

      )

    )


# Exports
#
cc.module('react/company/profile').exports = MainComponent
