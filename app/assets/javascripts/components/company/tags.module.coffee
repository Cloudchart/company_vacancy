##= require ../../plugins/react_tokeninput/main
##= require ../../plugins/react_tokeninput/option

# Imports
# 
reactTag = React.DOM

TagStore        = require('stores/tag_store')
CompanyStore    = require('stores/company')
PostStore       = require('stores/post_store')

CompanyActions  = require('actions/company')
PostActions     = require('actions/post_actions')

TokenInput      = cc.require('plugins/react_tokeninput/main')
ComboboxOption  = cc.require('plugins/react_tokeninput/option')

IdentityStores =
  Company: CompanyStore
  Post: PostStore

IdentityActions = 
  Company: CompanyActions
  Post: PostActions

# Component
# 
Component = React.createClass

  syncIdentityTagNames: (identity_tags) ->
    tag_names = identity_tags.map((tag) -> tag.name)
    IdentityActions[@props.taggable_type].update(@props.taggable_id, { tag_names: tag_names })

  gatherTags: ->
    _.map @state.identity_tags, (tag) -> { id: tag.getKey(), name: "##{tag.name}" }
  
  gatherTagsForList: ->
    _.map @state.identity_tags, (identity_tag) => 
      (reactTag.li { 
        key: identity_tag.uuid
      },
        if @props.taggable_type == 'Company'
          (reactTag.a {
            href: "/companies/search"
            onClick: (event) =>
              event.preventDefault()
              @onTagClick(identity_tag.name)

          },
            "##{identity_tag.name}"
          )
        else
          "##{identity_tag.name}"
      )
  
  gatherTagsForSelect: ->
    query = @formatName(@state.query)
    
    _.chain(@state.tags)
      .reject (tag) => _.contains(@state.identity_tags.map((tag) -> tag.name), tag.name) or !tag.is_acceptable
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

      identity_tags = @state.identity_tags[..]
      identity_tags.push tag
      identity_tags = _.unique(identity_tags)

      @syncIdentityTagNames(identity_tags)


  onRemove: (object) ->
    identity_tags = _.reject @state.identity_tags, (tag) -> tag.uuid == object.id
    @syncIdentityTagNames(identity_tags)

  onTagClick: (value) ->
    csrfParam = document.querySelector('meta[name="csrf-param"]').getAttribute('content')
    csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

    @refs.tagLinkFormCsrfToken.getDOMNode().name = csrfParam
    @refs.tagLinkFormCsrfToken.getDOMNode().value = csrfToken
    @refs.tagLinkFormInput.getDOMNode().value = value
    @refs.tagLinkForm.getDOMNode().submit()

  getStateFromStores: (props) ->
    tags = TagStore.all()
    identity = IdentityStores[props.taggable_type].get(props.taggable_id)

    query: ''
    tags: tags
    identity: identity
    identity_tags: _.map(identity.tag_names, (name) -> _.find(tags, { name: name }))

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  getInitialState: ->
    @getStateFromStores(@props)

  render: ->
    if @props.readOnly and @state.identity_tags.length == 0
      null
    else
      (reactTag.div { className: "cc-hashtag-list" },
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
        ) if @props.taggable_type == 'Company'
      )


# Exports
# 
module.exports = Component
