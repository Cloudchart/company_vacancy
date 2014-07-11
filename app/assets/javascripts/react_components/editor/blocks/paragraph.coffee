##= require module
##= require placeholder

# Expose
#
tag         = React.DOM
placeholder = cc.require('placeholder')


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
        placeholder:  placeholder('react/editor/placeholders', "paragraph.#{@props.section}.#{@props.position}")
        onChange:     @onChange
      })
    )


# Expose
#
cc.react.editor.blocks.Paragraph = Component
