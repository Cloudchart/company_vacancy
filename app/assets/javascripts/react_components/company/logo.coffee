##= require module

# Imports
#
tag             = cc.require('react/dom')


attributes      =
  uuid:       'id'
  image:      'image'
  destroy:    '_destroy'


parameter_prefix = "company[logotype]"


# Main Component
#
MainComponent = React.createClass


  onSaveDone: (json) ->
    @setState
      image_url:  json.logotype_url
      image:          null
      destroy:        null
      synchronizing:  false
  
  
  onSaveFail: (json) ->
    @setState
      image:          null
      destroy:        null
      synchronizing:  false


  save: ->
    data = new FormData
    data.append("company[logotype]", @state.image) if @state.image
    data.append("company[remove_logotype]", true) if @state.destroy
    
    @setState
      image:          null
      destroy:        null
      synchronizing:  true
    
    $.ajax
      url:        @props.url
      type:       'PUT'
      dataType:   'json'
      data:       data
      contentType:  false
      processData:  false

    .done @onSaveDone
    .fail @onSaveFail
    


  onFileSelect: (event) ->
    file  = event.target.files[0]
    image = new Image
    
    image.onload = =>
      @setState
        image:      file
        image_url:  image.src
    
    image.src = URL.createObjectURL(file)

  
  onUpdateClick: ->
    @refs.file.getDOMNode().click()
  
  
  onDeleteClick: ->
    @setState
      image_url:  null
      destroy:    true


  getInitialState: ->
    image_url:      @props.logotype
    synchronizing:  false
  
  
  componentDidUpdate: (prevProps, prevState) ->
    @save() if @state.image or @state.destroy


  render: ->
    style                 = {}
    style.backgroundImage = "url(#{@state.image_url})" if @state.image_url
    
    (tag.aside {
      className:  'logo editor-image-uploader'
      style:      style
      onClick:    @onUpdateClick unless @state.image_url
    },
    
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
      ) if @state.image_url
      
      (tag.button {
        className:  'update orgpad small'
        onClick:    @onUpdateClick
      },
        'Change'
      ) if @state.image_url

      (tag.button {
        className:  'create orgpad small square'
        # onClick:    @onUpdateClick
      },
        (tag.i { className: 'fa fa-pencil'})
      ) unless @state.image_url

      unless @state.image_url or @state.synchronizing
        (tag.div {},
          (tag.i { className: 'fa fa-picture-o empty' }),
          (tag.br {})
          'Tap to add logo'
        )

      (tag.i { className: 'fa fa-cog fa-spin synchronizing' }) if @state.synchronizing
    )


# Exports
#
cc.module('react/company/logo').exports = MainComponent
