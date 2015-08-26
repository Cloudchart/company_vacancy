# @cjsx React.DOM

UserStore = require('stores/user_store.cursor')
constants = require('constants')


# Main component
#
Component = React.createClass

  displayName: 'InsightsSeeMore'

  propTypes:
    pinsSize: React.PropTypes.number.isRequired
    type: React.PropTypes.string.isRequired

  statics:
    takeSize: -> 6
    shouldDisplayComponent: (pinsSize) ->
      pinsSize >= 12 && !UserStore.me().get('is_authenticated')


  # Handlers
  #
  handleSignInClick: (event) ->
    location.href = constants.TWITTER_AUTH_PATH


  # Main render
  #
  render: ->
    return null unless Component.shouldDisplayComponent(@props.pinsSize)

    text =
      """
        Want to see <strong>#{@props.pinsSize - 6} more insights</strong> from this #{@props.type}?
        Log in and get those and access to other features!
      """

    <section className="see-more">
      <p dangerouslySetInnerHTML={ __html: text }></p>
      <button className="cc" onClick={@handleSignInClick}>{ "Log in with Twitter" }</button>
    </section>


# Export
#
module.exports = Component
