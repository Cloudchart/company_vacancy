# @cjsx React.DOM
#

# Imports
#
tag = React.DOM

PictureActions  = require('actions/picture_actions')
PictureStore    = require('stores/picture_store')

ImageInput      = require('components/form/image_input')
StandardButton  = require('components/form/buttons').StandardButton


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

sizeMapper =
  big:    "small"
  small:  "medium"
  medium: "big"

Component = React.createClass

  displayName: "Picture"

  statics:
    isEmpty: (block_id) ->
      !PictureStore.find (item) => item.uuid and item.owner_id == block_id and item.owner_type == 'Block'

  getInitialState: ->
    @getStateFromStores()
    
  getStateFromStores: ->
    picture: PictureStore.find (item) => item.owner_id == @props.uuid and item.owner_type == 'Block'
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())


  # Helpers
  #
  getClass: ->
    "picture-wrapper " + (if @state.picture then @state.picture.size else "big")

  getResizerIcon: ->
    if @state.picture.size == "big" then "fa fa-compress" else "fa fa-expand"
 

  # Handlers
  #
  handleChange: (file) ->
    if @state.picture
      PictureActions.update(@state.picture.uuid, { image: file })
    else
      PictureActions.create(@props.uuid, { image: file })

  handleResize: (event) ->
    return if @props.readOnly || !@state.picture.uuid
    
    event.preventDefault()
    event.stopPropagation()

    PictureActions.update(@state.picture.uuid, { size: sizeMapper[@state.picture.size] })



  # Lifecycle methods
  #
  componentDidMount: ->
    PictureStore.on('change', @refreshStateFromStores)
  
  componentWillUnmount: ->
    PictureStore.off('change', @refreshStateFromStores)


  renderImage: ->
    if @state.picture || @props.readOnly
      <img src = { @state.picture.url } />
    else
      <ImageInput
        onChange    = { @handleChange }
        readOnly    = { @props.readOnly } 
        placeholder = { <Placeholder /> } />


  render: ->
    <div className = { @getClass() }
         onClick   = { @handleResize }>
      { @renderImage() }
    </div>


# Exports
#
module.exports = Component
