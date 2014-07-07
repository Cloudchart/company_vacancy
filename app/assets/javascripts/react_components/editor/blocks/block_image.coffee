# Expose tags
#
tag = React.DOM


# Placeholders
#
placeholders =

  product:
    1: "Product picture goes here."

  default: "Default placeholder"


placeholder = (section, position) ->
  placeholders[section]?[position] || placeholders[section]?.default || placeholders.default


# Save
#
save = (url, data, onDone, onFail) ->
  $.ajax
    url:          url
    data:         data
    type:         'PUT'
    dataType:     'json'
    contentType:  false
    processData:  false
  .done onDone
  .fail onFail


# Lock component
#
LockComponent = React.createClass

  render: ->
    (tag.i { className: 'fa fa-lock lock' })

  
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
      (tag.p {}, "Use pictures at leat 1500px wide.")
    )



# Upload button component
#
UploadButtonComponent = React.createClass

  render: ->
    (tag.input {
      type:     'file'
      onChange: @props.onChange
    })


# Delete Button component
#
DeleteButtonComponent = React.createClass

  render: ->
    (tag.button {
      className: 'delete'
      onClick:    @props.onClick
    },
      "Delete"
      (tag.i { className: 'fa fa-times' })
    )


# Paragraph Block component
#
Component = React.createClass


  getInitialState: ->
    identity: @props.identities[0]
  
  
  # On save done
  onSaveDone: (json) ->
    @setState
      synchronizing:  false
      identity:       json.identities[0]
  
  
  # On save failr
  onSaveFail: ->
    @setState
      synchronizing:  false
    console.log 'fail'
    
  
  
  # Delete Button Click
  onDeleteButtonClick: (event) ->
    event.preventDefault()
    event.stopPropagation()
    
    data = new FormData
    data.append("block[identity_ids][]", "")

    @setState({ synchronizing: true })

    save(@props.url, data, @onSaveDone, @onSaveFail)
  
  
  # On file upload
  onFileUpload: (event) ->
    data = new FormData
    data.append("block[block_images_attributes][][image]", event.target.files[0])
    
    @setState({ synchronizing: true })

    save(@props.url, data, @onSaveDone, @onSaveFail)


  render: ->
    (tag.div { className: 'image' },
      (LockComponent {})                                          if @state.synchronizing
      (PlaceholderComponent {
        placeholder: placeholder(@props.section, @props.position)
      })                                                          unless @state.identity
      (tag.img { src: @state.identity.image })                    if @state.identity and !@state.synchronizing
      (UploadButtonComponent { onChange: @onFileUpload })         unless @state.synchronizing
      (DeleteButtonComponent { onClick: @onDeleteButtonClick })   if @state.identity and !@state.synchronizing
    )


# Expose
#
cc.react.editor.blocks.BlockImage = Component
