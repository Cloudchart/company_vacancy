###
  Used in:

  controllers/companies#settings
###

##= require module
##= require ./settings/slug
##= require ./settings/site_url
##= require ./settings/tag_list
##= require constants.module
##= require utils/uuid.module
##= require cloud_flux/mixins.module
##= require cloud_flux/store.module
##= require cloud_flux.module
##= require utils/event_emitter.module
##= require stores/company_store.module
##= require components/company/progress.module
##= require cloud_blueprint/components/inputs/date_input.module

# Imports
#
tag = React.DOM
company_attributes  = ['is_published', 'established_on', 'tag_list']

CompanyStore = require('stores/company_store')
TagStore = require('stores/tag_store')

UrlComponent = cc.require('react/company/settings/site_url')
SlugComponent = cc.require('react/company/settings/slug')
TagListComponent = cc.require('react/company/settings/tag_list')
ProgressComponent = require('components/company/progress')
DateInputComponent = require('cloud_blueprint/components/inputs/date_input')

# Main Component
#
MainComponent = React.createClass
  
  getInitialState: ->
    @getStateFromProps(@props)

  componentDidUpdate: (prevProps, prevState) ->
    @save() if @state.shouldSave and company_attributes.some((name) => @state[name] isnt prevState[name])

  componentDidMount: ->
    TagStore.on('change', @onTagStoreChange)

  componentWillUnmount: ->
    TagStore.off('change', @onTagStoreChange)
  
  onTagStoreChange: ->
    @setState({ all_tags: TagStore.all() })
  
  componentWillReceiveProps: (nextProps) ->
    @setState @getStateFromProps(nextProps)
  
  getStateFromProps: (props) ->
    is_published:      props.is_published
    established_on:    @formatDate(props.established_on)

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
    @setState @getInitialState()

  formatDate: (date) ->
    if date instanceof Date then date else Date.parse(date)

  onEstablishedOnChange: (value) ->
    value = if value == null then '' else value

    @setState
      established_on: value
      shouldSave: true

  onTagsChange: (event) ->
    @setState
      tag_list: event.target.value
      shouldSave: true

  handleProgressChange: (event) ->
    @setState
      is_published: event.target.value
      shouldSave: true

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

          (tag.div { className: 'profile-item' },
            (tag.div { className: 'content field' },
              (tag.label { htmlFor: 'established_on' }, 'Established on')

              (tag.div { className: 'spacer' })

              (DateInputComponent {
                id: 'established_on'
                name: 'established_on'
                date: @state.established_on
                placeholder: 'Jan 1, 2014'
                onChange: @onEstablishedOnChange
              })
            )
          )

          (TagListComponent {
            stored_tags:    @state.all_tags
            tags:           @props.tag_list
            onChange:       @onTagsChange
          })

        )
      )

      (tag.section { className: 'progress' },
        (tag.header {}, 'Progress')

        (ProgressComponent { 
          name: @props.name
          logotype: @props.logotype
          tag_list: @props.tag_list
          is_chart_with_nodes_created: @props.is_chart_with_nodes_created
          people: @props.people
          is_published: @state.is_published
          onChange: @handleProgressChange
        })
      )  
    )

# Exports
#
cc.module('react/company/settings').exports = MainComponent
