##= require ../../plugins/react_tokeninput/main
##= require ../../plugins/react_tokeninput/option
##= require utils/uuid.module
##= require utils/event_emitter.module
##= require cloud_flux/store.module
##= require cloud_flux/mixins.module
##= require cloud_flux.module
##= require stores/tag_store.module

# Imports
# 
tag = React.DOM

TokenInput      = cc.require('plugins/react_tokeninput/main')
ComboboxOption  = cc.require('plugins/react_tokeninput/option')
CloudFlux       = require('cloud_flux')
# TagActions      = -> require('actions/tag_actions')
# TagStore        = -> require('stores/tag_store')
# Constants       = -> require('constants')


# Main Component
# 
MainComponent = React.createClass


  mixins: [CloudFlux.mixins.Actions]
  

  syncTaggable: (tags) ->
    # console.log tags
    # tagNames = TagStore().filter((tag) -> tags.contains(tag.uuid)).map((tag) -> tag.name).join(',')
    tagNames = @props.all_tags.filter((tag) -> tags.contains(tag.uuid)).map((tag) -> tag.name).join(',')
    @props.onChange({ target: { value: tagNames }}) if _.isFunction(@props.onChange)
  
  
  # onCreate: (key) ->
  #   @addTag(key, false)
  #   @setState({ keys_to_create: @state.keys_to_create.push(key) })
  
  
  # onCreateDone: (key, json) ->
  #   if @state.keys_to_create.contains(key)
  #     @setState({ keys_to_create: @state.keys_to_create.remove(@state.keys_to_create.indexOf(key)) })

  #   @removeTag(key, false)
  #   @addTag(json.tag.uuid)
  
  
  # onCreateFail: (key) ->
  #   if @state.keys_to_create.contains(key)
  #     @setState({ keys_to_create: @state.keys_to_create.remove(@state.keys_to_create.indexOf(key)) })
    
  #   @removeTag(key, false)
  
  
  # getCloudFluxActions: ->
  #   actions = {}

  #   actions[Constants().Tag.CREATE]       = @onCreate
  #   actions[Constants().Tag.CREATE_DONE]  = @onCreateDone
  #   actions[Constants().Tag.CREATE_FAIL]  = @onCreateFail

  #   actions


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
    console.log name
    # TagActions().create(name)
    # @addTag(name)

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
    
    _(@props.all_tags)
      .reject (tag) => @state.tags.contains(tag.uuid) or !tag.is_acceptable
      .filter (tag) => query.length == 0 or tag.name.toLowerCase().indexOf(query) >= 0
      .value()


  getSelectedTags: ->
    _(@props.all_tags)
      .filter (tag) => @state.tags.contains(tag.uuid)
      .sortBy (tag) => @state.tags.indexOf(tag.uuid)
      .map (tag) => { key: tag.uuid, id: tag.uuid, name: tag.name }
      .value()
  

  onInput: (query) ->
    @setState({ query: query })


  onSelect: (value) ->
    if _.find(@props.all_tags, (tag) -> tag.uuid == value) then @addTag(value) else @createTag(value)


  onRemove: (value) ->
    @removeTag(value.key) if value


  getInitialState: ->
    tags:           new Immutable.Vector(@props.tag_list...)
    keys_to_create: new Immutable.Vector
    query:          ''


  render: ->
    (TokenInput {
      onInput:      @onInput
      onSelect:     @onSelect
      onRemove:     @onRemove
      selected:     @getSelectedTags()
      menuContent:  @gatherComboboxOptions()
    })

# Exports
# 
module.exports = MainComponent
