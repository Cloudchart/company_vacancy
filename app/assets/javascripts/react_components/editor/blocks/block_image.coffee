##= require module
##= require placeholder

# Expose
#
tag         = React.DOM
placeholder = cc.require('placeholder')


# Fields for ajax requests
#
ajaxAttributesPrefix = "block[block_images_attributes][]"

attributesForAjax =
  uuid: 'id'
  file: 'image'


# File input component
#
FileInputComponent = React.createClass

  render: ->
    (tag.input {
      type: 'file'
      ref: 'file-input'
      onChange: @props.onChange
    })


# Delete button component
#
DeleteButtonComponent = React.createClass

  render: ->
    (tag.button {
      className:  'delete'
      onClick:    @props.onClick
    },
      "Delete"
      (tag.i { className: 'fa fa-times' })
    )


# Placeholder component
#
PlaceholderComponent = React.createClass

  render: ->
    (tag.div { className: 'placeholder' },
      (tag.header {},
        (tag.i { className: 'fa fa-picture-o' })
        @props.placeholder
      )
      (tag.p {}, "Use professional photography or graphics design.")
      (tag.p {}, "Use pictures at least 1500px wide.")
    )


# BlockImage component
#
Component = React.createClass


  getInitialState: ->
    identity = @props.identities[0] || {}

    uuid:       identity.uuid
    url:        identity.url
    image_url:  identity.image
    file:       null


  onAjaxDone: (json) ->
    identity = json.identities[0] || {}

    @setState
      uuid:             identity.uuid
      url:              identity.url
      image_url:        identity.image
      is_synchronizing: false
  
  
  onAjaxFail: ->
    @setState
      is_synchronizing: false


  save: ->
    data = Object.keys(attributesForAjax).reduce (memo, key) =>
      memo.append("#{ajaxAttributesPrefix}[#{attributesForAjax[key]}]", @state[key]) if @state[key]
      memo
    , new FormData
    
    @setState
      file:             null
      is_synchronizing: true
    
    $.ajax
      url:          @props.url
      data:         data
      type:         'PUT'
      dataType:     'json'
      contentType:  false
      processData:  false
    .done @onAjaxDone
    .fail @onAjaxFail
  
  
  onDeleteDone: (json) ->
    @setState
      uuid:             null
      image_url:        null
      is_synchronizing: false
  
  
  onDeleteFail: ->
    @setState
      is_synchronizing: false
  

  delete: ->
    @setState
      file:             null
      is_synchronizing: true
    
    $.ajax
      url:        @state.url
      type:       'DELETE'
      dataType:   'json'
    .done @onDeleteDone
    .fail @onDeleteFail


  componentDidUpdate: ->
    @save() if @state.file

  onFileChange: (event) ->
    file = event.target.files[0] ; return unless file
    
    @setState
      file:       file
      image_url:  URL.createObjectURL(file)
  
  
  onImageLoad: ->
    URL.revokeObjectURL(@state.image_url)
  
  
  render: ->
    (tag.div { className: 'image' },
      (tag.img { src: @state.image_url, onLoad: @onImageLoad }) if @state.image_url
      (PlaceholderComponent {
        placeholder: placeholder('react/editor/placeholders', "block_image.#{@props.section}.#{@props.position}", ['block_image.default'])
      }) unless @state.image_url
      (FileInputComponent { onChange: @onFileChange }) unless @state.is_synchronizing
      (DeleteButtonComponent { onClick: @delete }) unless @state.is_synchronizing if @state.uuid
    )


# Expose
#
cc.react.editor.blocks.BlockImage = Component
