##= require ../../plugins/react_tokeninput/main
##= require ../../plugins/react_tokeninput/option

# Imports
# 
tag = React.DOM

TokenInput      = cc.require('plugins/react_tokeninput/main')
ComboboxOption  = cc.require('plugins/react_tokeninput/option')
CompanyActions  = require('actions/company')
CompanyStore    = require('stores/company')
TagStore        = require('stores/tag_store')

# Main Component
# 
MainComponent = React.createClass


  syncCompanyTagNames: (company_tags) ->
    tag_names = company_tags.map((tag) -> tag.name)
    CompanyActions.update(@props.key, { tag_names: tag_names })


  gatherTags: ->
    _.map @state.company_tags, (tag) -> { id: tag.name, name: tag.name }
  
  
  gatherTagsForSelect: ->
    query = @formatName(@state.query)
    
    _.chain(@state.tags)
      .reject (tag) => _.contains(@state.company_tags.map((tag) -> tag.name), tag.name) or !tag.is_acceptable
      .filter (tag) => query.length == 0 or tag.name.toLowerCase().indexOf(query) >= 0
      .map (tag) ->
        (ComboboxOption {
          key:    tag.getKey()
          value:  tag.name
        }, tag.name)
      .value()

  
  formatName: (name) ->
    name.trim().toLowerCase().replace(/[^a-z0-9\-_|\s]+/ig, '').replace(/\s{2,}/g, '-')


  onInput: (query) ->
    @setState(query: query)


  onSelect: (name) ->
    name = @formatName(name)

    tag = _.find @state.tags, name: name
    unless tag
      key = TagStore.create({ name: name })
      tag = TagStore.get(key)

    company_tags = @state.company_tags[..] ; company_tags.push tag
    @syncCompanyTagNames(company_tags)


  onRemove: (object) ->
    company_tags = _.reject @state.company_tags, (tag) -> tag.name == object.name
    @syncCompanyTagNames(company_tags)


  getStateFromStores: (props) ->
    tags      = TagStore.all()
    company   = CompanyStore.get(@props.key)

    query:          ''
    tags:           tags
    company:        company
    company_tags:   _.map(company.tag_names, (name) -> _.find(tags, { name: name }))


  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))


  getInitialState: ->
    @getStateFromStores(@props)


  render: ->
    (TokenInput {
      onInput:      @onInput
      onSelect:     @onSelect
      onRemove:     @onRemove
      selected:     @gatherTags()
      menuContent:  @gatherTagsForSelect()
    })


# Exports
# 
module.exports = MainComponent
