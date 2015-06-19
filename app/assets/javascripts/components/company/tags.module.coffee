# @cjsx React.DOM

# Imports
#

GlobalState     = require('global_state/state')

TokenInput      = cc.require('plugins/react_tokeninput/main')
ComboboxOption  = cc.require('plugins/react_tokeninput/option')

IdentityStores =
  Company:  require('stores/company')
  Post:     require('stores/post_store')

IdentityActions =
  Company:  require('actions/company')
  Post:     require('actions/post_actions')


# Utils
#
UUID = require('utils/uuid')


formatName = (name) ->
  name = name.trim().toLowerCase()
  name = name.replace(/[^a-z0-9\-_|\s]+/ig, '')
  name = name.replace(/\s{2,}/g, ' ')
  name = name.replace(/\s/g, '-')


# Component
#
Component = React.createClass


  syncIdentityTagNames: (tag_names) ->
    IdentityActions[@props.taggable_type].update(@props.taggable_id, { tag_names: tag_names })


  gatherTags: ->
    @state.identityTagNameSeq
      .sort (tagA, tagB) -> tagA.localeCompare(tagB)
      .map (tag) ->
        id:   tag
        name: '#' + tag

  gatherTagsForList: ->
    @gatherTags()
      .map (tag) => <li key={ tag.id }>{ tag.name }</li>
      .toArray()

  gatherTagsForSelect: ->
    query = formatName(@state.query)

    @state.tagSeq
      .filter (tag) => not @state.identityTagNameSeq.contains(tag.get('name'))
      .filter (tag) -> tag.get('name').indexOf(query) == 0 && query.length > 0
      .sort   (tagA, tagB) -> tagA.get('name').localeCompare(tagB.get('name'))
      .map    (tag) -> <ComboboxOption key={tag.get('name')} value={tag.get('name')}>{'#' + tag.get("name")}</ComboboxOption>


  getComponentChild: ->
    if @props.readOnly
      <ul>
        { @gatherTagsForList() }
      </ul>
    else
      <TokenInput
        onInput     = {@onInput}
        onSelect    = {@onSelect}
        onRemove    = {@onRemove}
        selected    = {@gatherTags().toArray()}
        menuContent = {@gatherTagsForSelect().toArray()}
        placeholder = {@props.placeholder}
      />


  onInput: (query) ->
    @setState(query: query)


  onSelect: (name) ->
    name = formatName(name) ; return if name.length == 0

    unless @state.tagNameSeq.contains(name)
      @props.cursor.set(UUID(), { name: name })

    tag_names = @state.identityTagNameSeq.toSet().add(name)

    @syncIdentityTagNames(tag_names.toArray())


  onRemove: (object) ->
    tag_names = @state.identityTagNameSeq.toSet().remove(object.id)
    @syncIdentityTagNames(tag_names.toArray())


  getStateFromProps: (props) ->
    tagSeq              = Immutable.Seq(@props.cursor.deref({}))
    identityTagNameSeq  = Immutable.Seq(IdentityStores[props.taggable_type].get(props.taggable_id).tag_names)

    query:              ''
    tagSeq:             tagSeq
    tagNameSeq:         tagSeq.map((tag) -> tag.get('name'))
    identityTagNameSeq: identityTagNameSeq


  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromProps(nextProps))


  getDefaultProps: ->
    placeholder: "#hashtag"
    cursor: GlobalState.cursor(['stores', 'tags', 'items'])


  getInitialState: ->
    @getStateFromProps(@props)


  render: ->
    return null if @props.readOnly and @state.identityTagNameSeq.size == 0

    <div className="cc-hashtag-list">{@getComponentChild()}</div>


# Exports
#
module.exports = Component
