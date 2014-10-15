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
TagStore        = require('stores/tag_store')
uuid            = require('utils/uuid')

# Main Component
# 
MainComponent = React.createClass


  syncTaggable: (tags) ->
    tagNames = @props.all_tags.filter((tag) -> tags.contains(tag.uuid)).map((tag) -> tag.name).join(',')
    @props.onChange({ target: { value: tagNames }}) if _.isFunction(@props.onChange)


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
    # uuid = uuid()
    # new_tag = TagStore.add(uuid, { uuid: uuid, name: name })
    # TagStore.emitChange()
    # console.log new_tag, new_tag.key, new_tag.uuid
    # tags = @state.tags.push(new_tag.key)
    # console.log tags
    # @setState({ query: '', tags: tags })

    tag_names = @props.all_tags.filter((tag) => @state.tags.contains(tag.uuid)).map((tag) -> tag.name)
    tag_names.push(name)
    @props.onChange({ target: { value: tag_names }})


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
