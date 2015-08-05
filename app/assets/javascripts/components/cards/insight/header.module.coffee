# @cjsx React.DOM

GlobalState     = require('global_state/state')

PinStore        = require('stores/pin_store')
UserStore       = require('stores/user_store.cursor')
PinboardStore   = require('stores/pinboard_store')


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
            }
          }
        """


  # Component Specifications
  #

  getDefaultProps: ->
    scope:                'pinboard'
    shouldRenderPinboard: true


  getInitialState: ->
    ready:      false
    pin:        {}
    user:       {}
    pinboard:   {}


  # Lifecycle Methods
  #

  componentDidMount: ->
    @fetch()


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pin', @props), { id: @props.pin }).then =>
      pin = PinStore.get(@props.pin).toJS()

      @setState
        ready:    true
        pin:      pin
        viewer:   UserStore.me().deref().toJS()
        user:     UserStore.get(pin.user_id).toJS()
        pinboard: PinboardStore.get(pin.pinboard_id).toJS() if pin.pinboard_id


  renderIcon: ->
    <i key='icon' className='fa fa-comment-o' />


  renderUserComment: (comment, options = {}) ->
    [
      @renderIcon() if options.icon
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
      else if @state.pin.content
        @renderUserComment('— ' + @state.pin.content, icon: true, prefix: 'in')
      else if @state.user.is_followed
        @renderUserComment('added insight', prefix: 'to')
      else
        <section className="title">
          { @renderPinboardTitle() }
        </section>
    else
      @renderUserComment('added insight', prefix: 'to')


  # Render pinboard header content
  #
  renderPinboardScopeContent: ->
    return null unless @state.pin.parent_id

    if @state.pinboard.is_editable
      if @state.pin.is_suggestion
        @renderUserComment('suggested insight')
      else if @state.pin.content
        @renderUserComment('— ' + @state.pin.content)
      else
        @renderUserComment('added insight')
    else
      @renderUserComment('— ' + @state.pin.content) if @state.pin.content unless @state.pin.is_suggestion


  renderContent: ->
    switch @props.scope
      when 'feed'       then @renderFeedScopeContent()
      when 'pinboard'   then @renderPinboardScopeContent()
      else nil


  # Main render
  #
  render: ->
    return null unless @state.ready
    return null unless content = @renderContent()

    <header>{ content }</header>
