# @cjsx React.DOM

GlobalState = require('global_state/state')


# Utils
#
colors    = require('utils/colors')
initials  = require('utils/initials')


# Exports
#
module.exports = React.createClass


  mixinx: [GlobalState.mixin]


  renderAvatar: ->
    person_initials = initials(@props.cursor.get('full_name'))
    avatar_url      = @props.cursor.get('avatar_url')
    
    style =
      backgroundColor:  if avatar_url then "none" else colors.colors[colors.colorIndex(person_initials)]
      backgroundImage:  if avatar_url then "url(#{avatar_url})" else "none"

    <figure style={ style }>
      <figcaption>
        { person_initials unless avatar_url }
      </figcaption>
    </figure>
  
  
  renderNameAndOccupation: ->
    <footer>
      <p className="name">
        { @props.cursor.get('full_name') }
      </p>
      <p className="occupation">
        { @props.cursor.get('occupation') }
      </p>
    </footer>
    


  render: ->
    <li className="person">
      { @renderAvatar() }
      { @renderNameAndOccupation() }
    </li>
