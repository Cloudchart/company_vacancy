# @cjsx React.DOM


# Main
#
module.exports = React.createClass

  displayName: "ImageInput"

  propTypes:
    onChange:    React.PropTypes.func
    onError:     React.PropTypes.func
    placeholder: React.PropTypes.component
    readOnly:    React.PropTypes.bool
    src:         React.PropTypes.string

  getDefaultProps: ->
    onChange:  ->
    onError:   ->
    readOnly:  true
  
  handleChange: (event) ->
    file  = event.target.files[0] ; return unless file
    image = new Image

    image.addEventListener 'load', =>
      @props.onChange(file)
      URL.revokeObjectURL(image.src)
    
    image.addEventListener 'error', =>
      @props.onError()
      URL.revokeObjectURL(image.src)

    image.src = URL.createObjectURL(file)


  # Renderers
  #
  renderInput: ->
    return null if @props.readOnly

    <input
      type     =   'file'
      onChange =   { @handleChange } 
      value    =   '' />

  renderImage: ->
    if @props.src
      @transferPropsTo(<img />)
    else
      @props.placeholder


  render: ->
    if @props.readOnly
      @renderImage()
    else
      <div className = 'image-input'>
        <label>
          { @renderInput() }
          { @renderImage() }
        </label>
      </div>
