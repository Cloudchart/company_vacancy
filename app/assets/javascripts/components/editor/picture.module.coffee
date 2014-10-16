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


  onChange: (file) ->
    if @state.picture
      PictureActions.update(@state.picture.uuid, { image: file })
    else
      PictureActions.create(@props.key, { image: file })


  onDelete: ->
    PictureActions.destroy(@state.picture.uuid)
  
  
  onError: ->
    console.log 'Error'
  
    
  getStateFromStores: ->
    picture: PictureStore.find (item) => item.owner_id == @props.key and item.owner_type == 'Block'
  
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  
  componentDidMount: ->
    PictureStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnmount: ->
    PictureStore.off('change', @refreshStateFromStores)


  getInitialState: ->
    @getStateFromStores()


  render: ->
    if @props.readOnly
      0 # render input and image
    else
      if @state.picture
        1 #render image
      else
        2 # render nothing
        
    if @state.picture or !@props.readOnly
      <ImageInput
        src={@state.picture.url if @state.picture}
        onChange={@onChange}
        onDelete={@onDelete}
        onError={@onError}
        readOnly={@props.readOnly} 
        placeholder={<Placeholder />}
      />
    else
      null


# Exports
#
module.exports = Component
