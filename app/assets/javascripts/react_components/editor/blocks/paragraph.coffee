# Expose
#
tag = React.DOM


# Placeholders
#
placeholders =

  about:
    0: "Tell a short story about your company — what does your company do and why it's important. Be brief, be clear, be straightforward. At about 70 words / 500 characters we'll crub your enthusiasm."

  product:
    0: "Tell us about your product or service. If you have several, add your bestseller or the one you're most proud of — you can add others later. About 70 words is enough."

  people:
    1: "Describe your team. Put forward the greatest and the brightest. Make sure they star prominently in your company chart. Up to 6 people should be enough for everyone."

  default: "Default placeholder"


placeholder = (section, position) ->
  placeholders[section]?[position] || placeholders[section]?.default || placeholders.default


# Attribute prefix
#
attributePrefix = "block[paragraphs_attributes][]"


# Keys for ajax requests
#
keysForCreate   = { content: 'content' }
keysForUpdate   = { content: 'content', id: 'uuid' }


# Paragraph component
#
Component = React.createClass


  emptyParagraph: ->
    uuid:     null
    content:  ''


  getInitialState: ->
    @props.identities[0] || @emptyParagraph()
  
  
  save: ->
    @setState
      synchronizing:        true
      should_save_content:  false

    return @create() unless @state.content.length == 0 unless @state.uuid
    return @update() unless @state.content.length == 0
    return @delete()
  
  
  onAjaxDone: (json) ->
    @setState json.identities[0]
    @setState
      synchronizing: false
  
  
  onAjaxFail: ->
    @setState
      synchronizing: false
  
  
  onDeleteDone: ->
    @setState @emptyParagraph()
    @setState
      synchronizing: false
  
  
  onDeleteFail: ->
    @setState
      synchronizing: false
  
  
  create: ->
    keys = keysForCreate
    data = Object.keys(keys).reduce ((memo, key) => memo.append("#{attributePrefix}[#{key}]", @state[keys[key]]) ; memo), new FormData
    
    $.ajax
      url:          @props.url
      data:         data
      type:         'PUT'
      dataType:     'json'
      contentType:  false
      processData:  false
    .done @onAjaxDone
  
  
  update: ->
    keys = keysForUpdate
    data = Object.keys(keys).reduce ((memo, key) => memo.append("#{attributePrefix}[#{key}]", @state[keys[key]]) ; memo), new FormData

    $.ajax
      url:          @props.url
      data:         data
      type:         'PUT'
      dataType:     'json'
      contentType:  false
      processData:  false
    .done @onAjaxDone
    .fail @onAjaxFail
  
  
  delete: ->
    $.ajax
      url:          @state.url
      type:         'DELETE'
      dataType:     'json'
    .done @onDeleteDone
    .fail @onDeleteFail
    

  onChange: (event) ->
    @setState
      content:              event.target.value
      should_save_content:  true

  
  componentDidUpdate: (prevProps, prevState) ->
    @save() if prevState.content != @state.content if @state.should_save_content
  

  render: ->
    (tag.div { className: 'paragraph' },
      (cc.react.editor.ContentEditableComponent {
        value:        @state.content
        placeholder:  placeholder(@props.section, @props.position)
        onChange:     @onChange
      })
    )


# Expose
#
cc.react.editor.blocks.Paragraph = Component
