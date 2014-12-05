# @cjsx React.DOM

# Imports
#
tag = React.DOM

ParagraphStore = require('stores/paragraph_store')

ParagraphActions = require('actions/paragraph_actions')

ContentEditableArea = require('components/form/contenteditable_area')

CompanyPlaceholder  = "Tell a short story about your company — what does your company do and why it’s important. Be brief, be clear, be straightforward. At about 70 words / 500 characters we’ll curb your enthusiasm."

findParagraph = (block_id) ->
  ParagraphStore.find (item) => item.uuid and item.owner_id is block_id and item.owner_type is 'Block'

# Main
#
Component = React.createClass

  statics:
    isEmpty: (block_id) ->
      !findParagraph(block_id)


  getValue: ->
    if @state.paragraph
      @state.paragraph.content
    else
      ''

  onChange: (content) ->
    return if @props.readOnly

    if @state.paragraph and @state.paragraph.uuid
      # destroy
      if content.length == 0
        ParagraphActions.destroy(@state.paragraph.uuid, @props.key)
      # update
      else if @state.paragraph.content isnt content
        ParagraphActions.update(@state.paragraph.uuid, @props.key, { content: content })
    # create
    else if content
      key = ParagraphStore.create({ owner_id: @props.key, owner_type: 'Block', content: content })
      ParagraphActions.create(key, ParagraphStore.get(key).toJSON())
  
  
  componentWillReceiveProps: ->
    @refreshStateFromStores()
  
  
  componentDidMount: ->
    ParagraphStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnmount: ->
    ParagraphStore.off('change', @refreshStateFromStores)
  
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  
  getStateFromStores: ->
    paragraph: findParagraph(@props.key)
    
  
  getInitialState: ->
    @getStateFromStores()


  render: ->
    <ContentEditableArea
      onChange={@onChange}
      placeholder={CompanyPlaceholder}
      readOnly={@props.readOnly}
      value={@getValue()}
    />


# Exports
#
module.exports = Component
