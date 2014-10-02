# Imports
#
tag = React.DOM

ParagraphStore      = require('stores/paragraph_store')
ParagraphActions    = require('actions/paragraph_actions')

ContentEditableArea = require('components/form/contenteditable_area')

CompanyPlaceholder  = "Tell a short story about your company — what does your company do and why it’s important. Be brief, be clear, be straightforward. At about 70 words / 500 characters we’ll curb your enthusiasm."


# Main
#
Component = React.createClass


  getKey: ->
    if @state and @state.key and ParagraphStore.has(@state.key)
      @state.key
    else
      paragraph = ParagraphStore.find((item) => item.owner_id is @props.key and item.owner_type is 'Block')
      if paragraph and paragraph.uuid
        paragraph.uuid
      else
        ParagraphStore.create({ owner_id: @props.key, owner_type: 'Block' })
  
  
  update: (content) ->
    if @state.paragraph.content isnt content
      ParagraphActions.update(@state.key, { content: content })
  
  
  delete: ->
    if @state.paragraph.uuid
      ParagraphActions.delete(@state.key)


  onChange: (content) ->
    if content.length == 0
      @delete()
    else
      @update(content)
  
  
  getStateFromStores: ->
    key = @getKey()
    
    key:        key
    paragraph:  ParagraphStore.get(key)
  
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  
  componentDidMount: ->
    ParagraphStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnmount: ->
    ParagraphStore.off('change', @refreshStateFromStore)
  
  
  componentWillReceiveProps: ->
    @refreshStateFromStores()
    
  
  getInitialState: ->
    @getStateFromStores()


  render: ->
    (tag.section {
      className: 'paragraph'
    },
    
      (ContentEditableArea {
        onChange:     @onChange
        placeholder:  CompanyPlaceholder
        value:        @state.paragraph.content
      })
      
    )


# Exports
#
module.exports = Component
