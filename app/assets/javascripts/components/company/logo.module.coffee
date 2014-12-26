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
        backgroundColor: if @props.logoUrl then "none" else (@props.backgroundColor || getColorByLetters(letters))
        backgroundImage: if @props.logoUrl then "url('#{@props.logoUrl}')" else "none"
    },
      letters unless @props.logoUrl
    )

module.exports = Component
