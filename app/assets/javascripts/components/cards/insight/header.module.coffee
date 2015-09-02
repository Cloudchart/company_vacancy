# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')
UserStore = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')

Reflection = require('components/cards/insight/header/reflection')
Pinboard = require('components/cards/insight/header/pinboard')
Feed = require('components/cards/insight/header/feed')


# Utils
#
# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'InsightCardHeader'

  propTypes:
    pin:    React.PropTypes.string.isRequired
    scope:  React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      pin: ->
        """
          Pin {
            pinboard {
              edges {
                is_editable
              }
            },
            user {
              edges {
                is_followed
              }
            },
            parent {
              edges {
                should_show_reflection
              }
            },
            edges {
              should_show_reflection
            }
          }
        """


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pin', @props), { id: @props.pin }).then =>
      pin = PinStore.get(@props.pin).toJS()

      @setState
        ready:    true
        pin:      pin
        viewer:   UserStore.me().deref(Immutable.Seq()).toJS()
        user:     UserStore.get(pin.user_id).toJS()
        pinboard: PinboardStore.get(pin.pinboard_id).toJS() if pin.pinboard_id


  # Component Specifications
  #
  getDefaultProps: ->
    scope: 'pinboard'

  getInitialState: ->
    ready:      false
    pin:        {}
    user:       {}
    pinboard:   {}


  # Lifecycle Methods
  #
  componentDidMount: ->
    @fetch()


  renderIcon: (icon) ->
    return null unless icon
    <i key='icon' className="fa fa-#{icon}" />


  renderUserComment: (comment, options = {}) ->
    [
      @renderIcon(options.icon)
      <section key="title" className="title">
        <a className='user' href={ @state.user.url }>{ @state.user.full_name }</a>
        <span className='comment'>{ comment }</span>
        { @renderPinboardTitle(options.prefix) }
      </section>
    ]


  renderPinboardTitle: (prefix) ->
    return null if @props.scope == 'pinboard'
    return null unless @state.pinboard
    [
      <span key='prefix'>{ prefix }</span>
      <a href={ @state.pinboard.url } key='pinboard' className='pinboard see-through'>{ @state.pinboard.title }</a>
    ]



  # Render feed header content
  #
  renderFeedScopeContent: ->
    if @state.pin.parent_id
      if @state.pin.is_suggestion
        @renderUserComment('suggested insight', prefix: 'to')
      else if @state.pin.kind == 'reflection'
        text = if @state.pin.content then "added reflection – #{@state.pin.content}" else 'added reflection'
        icon = if @state.pin.is_approved then 'thumbs-o-up' else 'thumbs-o-down'
        @renderUserComment(text, icon: icon)
      else if @state.pin.content
        @renderUserComment('— ' + @state.pin.content, icon: 'comment-o', prefix: 'in')
      else if @state.user.is_followed
        @renderUserComment('added insight', prefix: 'to')
      else
        <section className="title">
          { @renderPinboardTitle() }
        </section>
    else
      if @state.user.is_followed
        @renderUserComment('added insight', prefix: 'to')
      else
        <section className="title">
          { @renderPinboardTitle() }
        </section>


  # Main render
  #
  render: ->
    return null unless @state.ready

    if @state.pin.should_show_reflection
      <Reflection insight={ @state.pin.id } />
    else
      switch @props.scope
        when 'pinboard' then <Pinboard pin = { @state.pin } />
        when 'feed' then <Feed />
        else null
