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
CompanyStore    = require('stores/company')
TagStore        = require('stores/tag_store')

# Main Component
# 
MainComponent = React.createClass


  syncTaggable: (tags) ->
    tag_names = @props.all_tags.filter((tag) -> tags.contains(tag.uuid)).map((tag) -> tag.name).join(',')
    CompanyActions.update(@props.key, tag_list: tag_names)


  #addTag: (key, sync = true) ->
  #  unless @state.tags.contains(key)
  #    tags = @state.tags.push(key)
  #    @syncTaggable(tags) if sync
  #    @setState({ query: '', tags: tags })
  addTag: (key, sync = true) ->
    #CompanyActions
    list = @props.tag_list[..] ; list.push(key) ; list = _.map list, (key) -> TagStore.get(key).name
    CompanyActions.update(@props.key, { tag_list: list })
    
  
  
  removeTag: (key, sync = true) ->
    if @state.tags.contains(key)
      tags = @state.tags.remove(@state.tags.indexOf(key))
      @syncTaggable(tags) if sync
      @setState({ query: '', tags: tags })
  
  
  createTag: (name) ->
    tag_list = @state.company.tag_list[..] ; tag_list.push(TagStore.create({ name: name }))
    CompanyActions.update(@props.key, tag_list: tag_list)

    #CompanyStore.update(@props.key, tag_list: )
    #CompanyStore.emitChange()
    # new_tag_key = TagActions.create(name)
    # @addTag(new_tag_key, false)

    # syncTaggable for create
    #tag_names = @props.all_tags.filter((tag) => @state.tags.contains(tag.uuid)).map((tag) -> tag.name)
    #tag_names.push(name)
    #CompanyActions.update(@props.key, tag_list: tag_names.join(','))
  
  

  gatherTags: ->
    _.map @state.company_tags, (tag) -> { id: tag.getKey(), name: tag.name }
  
  

  gatherTagsForSelect: ->
    query = @state.query.trim().toLowerCase()
    
    _.chain(@state.tags)
      .reject (tag) => _.contains(@state.company.tag_list, tag.getKey()) or !tag.is_acceptable
      .filter (tag) => query.length == 0 or tag.name.toLowerCase().indexOf(query) >= 0
      .map (tag) ->
        (ComboboxOption {
          key:    tag.getKey()
          value:  tag.getKey()
        }, tag.name)
      .value()
      
    


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
    
    _(@state.tag_list)
      .reject (tag) => _.contains(@state.company.tag_list, tag.getKey()) or !tag.is_acceptable
      .filter (tag) => query.length == 0 or tag.name.toLowerCase().indexOf(query) >= 0
      .value()
    
    
    #_(@props.all_tags)
    #  .reject (tag) => @state.tags.contains(tag.uuid) or !tag.is_acceptable
    #  .filter (tag) => query.length == 0 or tag.name.toLowerCase().indexOf(query) >= 0
    #  .value()


  getSelectedTags: ->
    #_(@props.all_tags)
    _(@state.tag_list)
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
    
  
  getStateFromProps: (props) ->
    tags      = TagStore.all()
    company   = CompanyStore.get(@props.key)

    tags:           tags
    company:        company
    company_tags:   tags.filter (tag) -> _.contains company.tag_list, tag.getKey()


  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromProps(nextProps))
    #console.log nextProps.tag_list
    #if typeof nextProps.tag_list == 'object'
    #  @setState({ tags: new Immutable.Vector(nextProps.tag_list...) })


  getInitialState: ->
    state = @getStateFromProps(@props)
    # tags: new Immutable.Vector(@props.tag_list...)
    state.query = ''
    state


  render: ->
    (TokenInput {
      onInput:      @onInput
      onSelect:     @onSelect
      onRemove:     @onRemove
      selected:     @gatherTags() #@getSelectedTags()
      menuContent:  @gatherTagsForSelect() #@gatherComboboxOptions()
    })

# Exports
# 
module.exports = MainComponent
