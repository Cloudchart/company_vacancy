##= require ../../../plugins/react_tokeninput/main
##= require ../../../plugins/react_tokeninput/option
##= require utils/uuid.module
##= require utils/event_emitter.module
##= require cloud_flux/store.module
##= require cloud_flux/mixins.module
##= require cloud_flux.module

# Imports
# 
tag = React.DOM

TokenInput      = cc.require('plugins/react_tokeninput/main')
ComboboxOption  = cc.require('plugins/react_tokeninput/option')
CloudFlux       = require('cloud_flux')
TagActions      = -> require('actions/tag_actions')
TagStore        = -> require('stores/tag_store')
Constants       = -> require('constants')


# Main Component
# 
MainComponent = React.createClass


  mixins: [CloudFlux.mixins.Actions]
  

  syncTaggable: (tags) ->
    tagNames = TagStore().filter((tag) -> tags.contains(tag.uuid)).map((tag) -> tag.name).join(',')
    @props.onChange({ target: { value: tagNames }}) if _.isFunction(@props.onChange)
  
  
  onCreate: (key) ->
    @addTag(key, false)
    @setState({ keys_to_create: @state.keys_to_create.push(key) })
  
  
  onCreateDone: (key, json) ->
    if @state.keys_to_create.contains(key)
      @setState({ keys_to_create: @state.keys_to_create.remove(@state.keys_to_create.indexOf(key)) })

    @removeTag(key, false)
    @addTag(json.tag.uuid)
  
  
  onCreateFail: (key) ->
    if @state.keys_to_create.contains(key)
      @setState({ keys_to_create: @state.keys_to_create.remove(@state.keys_to_create.indexOf(key)) })
    
    @removeTag(key, false)
  
  
  getCloudFluxActions: ->
    actions = {}

    actions[Constants().Tag.CREATE]       = @onCreate
    actions[Constants().Tag.CREATE_DONE]  = @onCreateDone
    actions[Constants().Tag.CREATE_FAIL]  = @onCreateFail

    actions


  addTag: (key, sync = true) ->
    unless @state.tags.contains(key)
      tags = @state.tags.push(key)
      @syncTaggable(tags) if sync
      @setState({ query: '', tags: tags })
  
  
  removeTag: (key, sync = true) ->
    if @state.tags.contains(key)
      tags = @state.tags.remove(@state.tags.indexOf(key))
      @syncTaggable(tags) if sync
      @setState({ query: '', tags: tags })
  
  
  createTag: (name) ->
    TagActions().create(name)


  gatherComboboxOptions: ->
    _.map @getAvailableTags(), (tag) =>
      (ComboboxOption {
        key:    tag.uuid
        value:  tag.uuid
      },
        tag.name
      )


  getAvailableTags: ->
    query = @state.query.trim().toLowerCase()
    
    _(@props.stored_tags)
      .reject (tag) => @state.tags.contains(tag.uuid)
      .filter (tag) => query.length == 0 or tag.name.toLowerCase().indexOf(query) >= 0
      .value()


  getSelectedTags: ->
    _(@props.stored_tags)
      .filter (tag) => @state.tags.contains(tag.uuid)
      .sortBy (tag) => @state.tags.indexOf(tag.uuid)
      .map (tag) => { key: tag.uuid, id: tag.uuid, name: tag.name, sync: TagStore().is_in_sync(tag.uuid) }
      .value()
  

  onInput: (query) ->
    @setState({ query: query })


  onSelect: (value) ->
    if TagStore().has(value) then @addTag(value) else @createTag(value)


  onRemove: (value) ->
    @removeTag(value.key) if value
      

  getInitialState: ->
    tags:           new Immutable.Vector(@props.tags...)
    keys_to_create: new Immutable.Vector
    query:          ''


  render: ->
    (tag.div { className: 'profile-item' },
      (tag.div { className: 'content field' },
        (tag.label { htmlFor: 'tag_list' }, 'Tags')
        (tag.div { className: 'spacer' })
        (tag.div { className: 'tags' },

          (TokenInput {
            onChange:     @onChange
            onInput:      @onInput
            onSelect:     @onSelect
            onRemove:     @onRemove
            selected:     @getSelectedTags()
            menuContent:  @gatherComboboxOptions()
          })

        )

      )
    )

# Exports
# 
cc.module('react/company/settings/tag_list').exports = MainComponent
