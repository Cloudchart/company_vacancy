###
  Used in:
  components/company/preview/item
###

tag = React.DOM
cx = React.addons.classSet

getColorByLetters = cc.require('cc.utils.Colors.getColorByLetters')
Letters           = cc.require('cc.utils.Letters')

Component = React.createClass

  render: ->
    letters = Letters(@props.value)

    (tag.figure {
      className:
        cx({ "image-absent": !@props.logoUrl })
      style:
        backgroundColor: @props.backgroundColor || getColorByLetters(letters) unless @props.logoUrl
    },
      tag.img { src: @props.logoUrl } if @props.logoUrl
      letters unless @props.logoUrl
    )

module.exports = Component
