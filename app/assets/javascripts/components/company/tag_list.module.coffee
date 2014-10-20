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
TagActions      = require('actions/tag_actions')
CompanyActions  = require('actions/company')

# Main Component
# 
MainComponent = React.createClass


  syncTaggable: (tags) ->
    tag_names = @props.all_tags.filter((tag) -> tags.contains(tag.uuid)).map((tag) -> tag.name).join(',')
    CompanyActions.update(@props.key, tag_list: tag_names)


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
    # new_tag_key = TagActions.create(name)
    # @addTag(new_tag_key, false)

    # syncTaggable for create
    tag_names = @props.all_tags.filter((tag) => @state.tags.contains(tag.uuid)).map((tag) -> tag.name)
    tag_names.push(name)
    CompanyActions.update(@props.key, tag_list: tag_names.join(','))


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


  componentWillReceiveProps: (nextProps) ->
    console.log nextProps.tag_list
    if typeof nextProps.tag_list == 'object'
      @setState({ tags: new Immutable.Vector(nextProps.tag_list...) })


  getInitialState: ->
    # tags: new Immutable.Vector(@props.tag_list...)
    query: ''


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
