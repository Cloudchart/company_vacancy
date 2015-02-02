###
  Used in:

  components/editor/IdentitySelector
###

# Imports
#
tag = React.DOM


# Main Component
#
Component = React.createClass


  onIdentityClick: (key) ->
    @props.onSelect(key) if _.isFunction(@props.onSelect)


  gatherIdentities: ->
    _.map @props.children, (child) =>
      (tag.li {
        key:        child.props.key
        className: 'identity'
        onClick:    @onIdentityClick.bind(@, child.props.key)
      },
        child
      )
  
  
  render: ->
    (tag.ul {
      className: 'identity-list'
    },
      @gatherIdentities()
    )


# Exports
#
cc.module('cc.components.IdentityList').exports = Component
