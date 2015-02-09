# @cjsx React.DOM
#

# Imports
#
tag = React.DOM

PictureActions  = require('actions/picture_actions')
PictureStore    = require('stores/picture_store')

ImageInput      = require('components/form/image_input')


# Placeholder
#
Placeholder = (title) ->
  <div className="placeholder">
    <div className="content">
      <header>
        <i className="fa fa-picture-o" />
        Product picture goes here
      </header>
      <p>
        Use professional photography or graphics design.
      </p>
      <p>
        Use pictures at least 1500 px wide with a ratio of 4:3.
      </p>
      <p>
        1600x1200 px is a good start.
      </p>
    </div>
  </div>


# Main
#
Component = React.createClass

  statics:
    isEmpty: (block_id) ->
      !PictureStore.find (item) => item.uuid and item.owner_id == block_id and item.owner_type == 'Block'

  onChange: (file) ->
    if @state.picture
      PictureActions.update(@state.picture.uuid, { image: file })
    else
      PictureActions.create(@props.uuid, { image: file })


  onDelete: ->
    PictureActions.destroy(@state.picture.uuid)
  
  
  onError: ->
    console.log 'Error'
  
    
  getStateFromStores: ->
    picture: PictureStore.find (item) => item.owner_id == @props.uuid and item.owner_type == 'Block'
  
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  
  componentDidMount: ->
    PictureStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnmount: ->
    PictureStore.off('change', @refreshStateFromStores)


  getInitialState: ->
    @getStateFromStores()


  render: ->        
    <ImageInput
      src={@state.picture.url if @state.picture}
      onChange={@onChange}
      onDelete={@onDelete}
      onError={@onError}
      readOnly={@props.readOnly} 
      placeholder={<Placeholder />}
    />


# Exports
#
module.exports = Component
