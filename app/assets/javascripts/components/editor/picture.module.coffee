# Imports
#
tag = React.DOM

BlockActions  = require('actions/block_actions')
BlockStore    = require('stores/block_store')
PictureStore  = require('stores/picture_store')

ImageInput    = require('components/form/image_input')


# Placeholder
#
Placeholder = (title) ->
  (tag.div {
    className: 'placeholder'
  },
    (tag.header null,
      (tag.i { className: 'fa fa-picture-o' })
      "Product picture goes here"
    )
    
    (tag.p null,
      "Use professional photography or graphics design."
    )
    
    (tag.p null,
      "Use pictures at least 1500 px wide with a ratio of 4:3."
    )
    
    (tag.p null,
      "1600x1200 px is a good start."
    )
  )


# Main
#
Component = React.createClass


  onChange: (file) ->
    BlockActions.update @props.key,
      "block[pictures_attributes][][image]": file


  onDelete: ->
    if @props.block.identity_ids.length > 0
      BlockActions.update @props.key,
        "block[identity_ids][]": []
  
  
  onError: ->
    console.log 'Error'
  
  
  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))
  
  
  getStateFromStores: (props) ->
    src: if (picture = PictureStore.get(props.block.identity_ids[0])) then picture.url else null


  getInitialState: ->
    @getStateFromStores(@props)


  render: ->
    (tag.section {
      className: 'picture'
    },

      (ImageInput {
        src:          @state.src
        onChange:     @onChange
        onDelete:     @onDelete
        onError:      @onError
        placeholder:  (Placeholder {})
      })
      
    )


# Exports
#
module.exports = Component
