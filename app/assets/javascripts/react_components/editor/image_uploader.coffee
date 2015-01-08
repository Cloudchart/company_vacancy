##= require module

tag = cc.require('react/dom')


MainComponent = React.createClass


  cleanupImage: (image) ->
    URL.revokeObjectURL(image.src)


  onChangeClick: ->
    @refs.file.getDOMNode().click()
  
  
  onDeleteClick: ->
    @props.onDelete() if @props.onDelete instanceof Function
  
  
  onFileSelect: (event) ->
    file  = event.target.files[0]
    image = new Image
    
    image.onload = =>
      @setState
        image:  file
        url:    image.src
      
    image.src = URL.createObjectURL(file)
  
  
  componentWillReceiveProps: (nextProps) ->
    # console.log nextProps
    @setState
      image:  null
      url:    nextProps.url
  
  
  componentDidUpdate: (prevProps, prevState) ->
    @props.onFileSelect({ target: { file: @state.image, url: @state.url }}) if @state.image and @props.onFileSelect instanceof Function
    
  
  getInitialState: ->
    image:  null
    url:    @props.url
  
  
  render: ->
    (tag.div { className: 'editor-image-uploader' },
      (tag.input {
        ref:        'file'
        type:       'file'
        onChange:   @onFileSelect
      })
      
      (tag.button {
        className:  'delete orgpad alert small'
        onClick:    @onDeleteClick
      },
        'Delete'
      )
      
      (tag.button {
        className:  'update orgpad small'
        onClick:    @onChangeClick
      },
        'Change'
      )
      
      (tag.button {
        className: 'create'
      },
        (tag.i { className: 'fa fa-pencil' })
      ) if false
    )


@cc.module('react/editor/image-uploader').exports = MainComponent
