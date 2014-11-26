##= require ../../plugins/react_tokeninput/main
##= require ../../plugins/react_tokeninput/option

# Imports
# 
reactTag = React.DOM

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
    CompanyActions.update(@props.uuid, { tag_names: tag_names })


  gatherTags: ->
    _.map @state.company_tags, (tag) -> { id: tag.getKey(), name: "##{tag.name}" }
  
  gatherTagsForList: ->
    _.map @state.company_tags, (company_tag) => 
      (reactTag.li { 
        key: company_tag.uuid
      },
        reactTag.a {
          href: "/companies/search"
          onClick: (event) =>
            event.preventDefault()
            @onTagClick(company_tag.name)

        },
          "##{company_tag.name}"
      )
  
  gatherTagsForSelect: ->
    query = @formatName(@state.query)
    
    _.chain(@state.tags)
      .reject (tag) => _.contains(@state.company_tags.map((tag) -> tag.name), tag.name) or !tag.is_acceptable
      .filter (tag) => tag.name.toLowerCase().indexOf(query) >= 0
      .map (tag) ->
        (ComboboxOption {
          key:    tag.getKey()
          value:  tag.name
        }, "##{tag.name}")
      .value()

  
  formatName: (name) ->
    name = name.trim().toLowerCase()
    name = name.replace(/[^a-z0-9\-_|\s]+/ig, '')
    name = name.replace(/\s{2,}/g, ' ')
    name = name.replace(/\s/g, '-')


  onInput: (query) ->
    @setState(query: query)


  onSelect: (name) ->
    name = @formatName(name)

    if name.length > 0
      tag = _.find @state.tags, name: name
      unless tag
        key = TagStore.create({ name: name })
        tag = TagStore.get(key)

      company_tags = @state.company_tags[..]
      company_tags.push tag
      company_tags = _.unique(company_tags)

      @syncCompanyTagNames(company_tags)


  onRemove: (object) ->
    company_tags = _.reject @state.company_tags, (tag) -> tag.uuid == object.id
    @syncCompanyTagNames(company_tags)

  onTagClick: (value) ->
    csrfParam = document.querySelector('meta[name="csrf-param"]').getAttribute('content')
    csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

    @refs.tagLinkFormCsrfToken.getDOMNode().name = csrfParam
    @refs.tagLinkFormCsrfToken.getDOMNode().value = csrfToken
    @refs.tagLinkFormInput.getDOMNode().value = value
    @refs.tagLinkForm.getDOMNode().submit()

  getStateFromStores: (props) ->
    tags      = TagStore.all()
    company   = CompanyStore.get(@props.uuid)

    query:          ''
    tags:           tags
    company:        company
    company_tags:   _.map(company.tag_names, (name) -> _.find(tags, { name: name }))


  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  getDefaultProps: ->
    readOnly: false

  getInitialState: ->
    @getStateFromStores(@props)


  render: ->

    (reactTag.div { className: "tags" },
      (
        if @props.readOnly
          (reactTag.ul null,
            @gatherTagsForList()
          )
        else
          (TokenInput {
            onInput:      @onInput
            onSelect:     @onSelect
            onRemove:     @onRemove
            onTagClick:   @onTagClick
            selected:     @gatherTags()
            menuContent:  @gatherTagsForSelect()
            placeholder:  "#hashtag"
          })
      )
      (reactTag.form 
        ref: "tagLinkForm"
        action: "/companies/search"
        method: "POST"
        ,
        reactTag.input
          ref: "tagLinkFormCsrfToken"
          type: "hidden"

        reactTag.input 
          ref: "tagLinkFormInput"
          name: "query"
          type: "hidden"
      )
    )


# Exports
# 
module.exports = MainComponent
