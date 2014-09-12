# Imports
#
tag = React.DOM


# Main
#
Component = React.createClass


  render: ->
    if @props.settings.isIdentityBoxVisible
      (tag.div {
        style:
          backgroundColor: '#eee'
          width: 200
      },
        'Identity box goes here'
      )
    else
      (tag.noscript null)


# Exports
#
module.exports = Component
