# = require ./owners

##= require module
##= require ./settings/slug
##= require ./settings/site_url
##= require ./settings/established_on
##= require ./settings/tag_list
##= require constants.module
##= require utils/uuid.module
##= require cloud_flux/mixins.module
##= require cloud_flux/store.module
##= require cloud_flux.module
##= require utils/event_emitter.module
##= require stores/company_store.module
##= require stores/tag_store.module
##= require components/company/progress.module

tag = React.DOM
company_attributes  = ['is_published', 'established_on', 'tag_list']
CompanyStore        = require('stores/company_store')
TagStore            = require('stores/tag_store')
TagActions          = -> require('actions/tag_actions')

# Imports
#
# CompanyOwnersComponent  = cc.require('react/company/owners')
UrlComponent = cc.require('react/company/settings/site_url')
SlugComponent = cc.require('react/company/settings/slug')
EstablishedOnComponent = cc.require('react/company/settings/established_on')
TagListComponent = cc.require('react/company/settings/tag_list')
ProgressComponent = require('components/company/progress')

# Main Component
#
MainComponent = React.createClass
  
  getInitialState: ->
    state = @getStateFromProps(@props)
    _.extend state, @getStateFromStore()
    state
  
  
  componentDidMount: ->
    TagStore.on('change', @refreshStateFromStore)
    TagActions().fetch()
  
  
  componentWillUnmount: ->
    TagStore.off('change', @refreshStateFromStore)


  componentDidUpdate: (prevProps, prevState) ->
    @save() if @state.shouldSave and company_attributes.some((name) => @state[name] isnt prevState[name])
  
  
  componentWillReceiveProps: (nextProps) ->
    @setState @getStateFromProps(nextProps)
  
  
  refreshStateFromStore: ->
    @setState(@getStateFromStore())
  
  
  getStateFromStore: ->
    tags: TagStore.all()
  
  
  getStateFromProps: (props) ->
    is_published:      props.is_published
    established_on:    props.established_on

  save: ->
    @setState({ shouldSave: false })

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
    CompanyStore.update(@props.uuid, @getStateFromProps(json))

  onSaveFail: ->
    console.warn 'Save Fail'

  onEstablishedOnChange: (event) ->
    @setState
      established_on: event.target.value
      shouldSave: true

  onTagsChange: (event) ->
    @setState
      tag_list: event.target.value
      shouldSave: true

  handleProgressChange: (event) ->
    console.log event.target.value

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
            verify_site_url: @props.settings.verify_site_url
            download_verification_file_url: @props.settings.download_verification_file_url
            is_site_url_verified: @props.settings.is_site_url_verified
          })

          (SlugComponent {
            value: @props.slug
            company_url: @props.company_url
            company_uuid: @props.uuid
            default_host: @props.default_host
          })

          (EstablishedOnComponent {
            value: @state.established_on
            onChange: @onEstablishedOnChange
          })

          (TagListComponent {
            stored_tags:    @state.tags
            tags:           @props.tags
            onChange:       @onTagsChange
          })

        )
      )

      (tag.section { className: 'progress' },
        (tag.header {}, 'Progress')
        
        (ProgressComponent { 
          name: @props.name
          logotype: @props.logotype
          tags: @props.tags
          charts: @props.charts
          is_published: @state.is_published
          onChange: @handleProgressChange
        })
      )
  
      # deprecated
      # CompanyOwnersComponent({ owners: @props.owners, owner_invites: @props.owner_invites })
    )

# Exports
#
cc.module('react/company/settings').exports = MainComponent
