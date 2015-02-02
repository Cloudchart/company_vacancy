###
  Used in:

  components/Person
  components/Vacancy
  controllers/companies/invites#show
###

##= require utils/Colors
##= require utils/Letters

# Imports
#
tag = React.DOM


Colors      = cc.require('cc.utils.Colors')
ColorIndex  = cc.require('cc.utils.Colors.Index')
Letters     = cc.require('cc.utils.Letters')


# Main Component
#
Component = React.createClass


  getDefaultProps: ->
    value:                null
    backgroundColor:      null
    shouldRenderContent:  true


  render: ->
    letters = Letters(@props.value)
    (tag.figure {
      style:
        backgroundColor:  @props.backgroundColor || Colors[ColorIndex(letters)]
        backgroundImage:  if @props.avatarURL then "url('#{@props.avatarURL}')" else "none"
    },
      letters if @props.value and @props.shouldRenderContent unless @props.avatarURL
      @props.children if @props.shouldRenderContent
    )


# Exports
#
cc.module('cc.components.Avatar').exports = Component
