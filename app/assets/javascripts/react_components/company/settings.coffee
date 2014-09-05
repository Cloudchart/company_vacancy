##= require module
##= require ./owners
##= require ./settings/country_select
##= require ./settings/industry_select
##= require ./settings/short_name
##= require ./settings/site_url

tag = React.DOM
company_attributes = ['country', 'industry', 'is_listed']

# Imports
#
CountrySelectComponent = cc.require('react/company/country_select')
IndustrySelectComponent = cc.require('react/company/industry_select')
ShortNameComponent = cc.require('react/company/short_name')
UrlComponent = cc.require('react/company/site_url')
CompanyOwnersComponent  = cc.require('react/company/owners')
# TransferOwnershipComponent = cc.require('react/company/transfer_ownership')

# Main Component
#
MainComponent = React.createClass

  render: ->
    (tag.article { className: 'editor settings' },
      (tag.section {
        className: 'profile'
      },
        (tag.header {}, 'Profile')
        
        (tag.div { className: 'section-block' },

          (UrlComponent {
            value: @props.site_url
            company_url: @props.company_url
            verify_site_url: @props.verify_site_url
            download_verification_file_url: @props.download_verification_file_url
            is_site_url_verified: @props.is_site_url_verified
          })

          (ShortNameComponent {
            value: @props.short_name
            company_url: @props.company_url
            company_uuid: @props.uuid
            default_host: @props.default_host
          })

          # (TransferOwnershipComponent {
          #   transfer_ownership_url: @props.transfer_ownership_url
          # })

          (tag.div { className: 'profile-item' },
            'Industry'
            (IndustrySelectComponent {
              value:      @state.industry
              onChange:   @onIndustryChange
            })
          )
          
          (tag.div { className: 'profile-item' },
            'Region'
            (CountrySelectComponent {
              value:      @state.country
              onChange:   @onCountryChange
            })
          )

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

      CompanyOwnersComponent({ owners: @props.owners, owner_invites: @props.owner_invites })

    )

  
  getInitialState: ->
    country:           @props.country
    industry:          @props.industry_ids[0]
    is_listed:         @props.is_listed

  componentDidUpdate: (prevProps, prevState) ->
    @save() if company_attributes.some((name) => @state[name] isnt prevState[name])

  save: ->
    data = company_attributes.reduce ((memo, name) => memo.append("company[#{name}]", @state[name]) if @state[name]?; memo), new FormData

    $.ajax
      url:        @props.company_url
      data:       data
      type:       'PUT'
      dataType:   'json'
      contentType:  false
      processData:  false

    .done @onSaveDone
    .fail @onSaveFail

  onSaveDone: (json) ->
    @setState
      country:        json.country
      industry:       json.industry_ids[0]
      is_listed:      json.is_listed
  
  onSaveFail: ->
    console.warn 'Save Fail'

  toggleListing: ->
    @setState
      is_listed: !@state.is_listed
  
  onCountryChange: (event) ->
    @setState
      country: event.target.value
  
  onIndustryChange: (event) ->
    @setState
      industry: event.target.value


# Exports
#
cc.module('react/company/settings').exports = MainComponent
