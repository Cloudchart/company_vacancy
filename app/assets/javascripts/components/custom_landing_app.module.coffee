# @cjsx React.DOM

GlobalState    = require('global_state/state')

LandingStore   = require('stores/landing_store')
UserStore      = require('stores/user_store.cursor')

LandingSyncApi = require('sync/landing_sync_api')

ContentEditableArea = require('components/form/contenteditable_area')
PersonAvatar        = require('components/shared/person_avatar')
StandardButton      = require('components/form/buttons').StandardButton

Constants = require('constants')

KnownAttributes = Immutable.Seq(['body', 'image_url'])

# Exports
#
module.exports = React.createClass

  displayName: 'CustomLandingApp'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:
      user: ->
        """
          User {
            landings {
              author
            }
          }
        """

      viewer: ->
        """
          Viewer {
            system_roles
          }
        """

  propTypes:
    uuid:    React.PropTypes.string.isRequired
    user_id: React.PropTypes.string.isRequired

  getDefaultProps: ->
    cursor:
      viewer:   UserStore.me()
      landings: LandingStore.cursor.items

  getInitialState: ->
    attributes:  Immutable.Map()

  fetch: ->
    Promise.all([
      GlobalState.fetch(@getQuery('user'), id: @props.user_id),
      GlobalState.fetch(@getQuery('viewer'))
    ]).then =>
      @setState
        attributes: @getAttributesFromCursor()
        isLoaded:   true


  # Helpers
  #
  isLoaded: ->
    @props.cursor.viewer.deref(false) && @state.isLoaded

  getLanding: ->
    @props.cursor.landings.cursor(@props.uuid).deref(Immutable.Map())

  getUser: ->
    UserStore.cursor.items.cursor(@props.user_id).deref(Immutable.Map())

  getAuthor: ->
    UserStore.cursor.items.cursor(@getLanding().get('author_id')).deref(Immutable.Map())

  getAttributesFromCursor: ->
    Immutable.Map().withMutations (attributes) =>
      KnownAttributes.forEach (name) =>
        attributes.set(name, @state.attributes.get(name) || @getLanding().get(name, '') || '')

      unless attributes.get('image_url', false)
        attributes.set('image_url', @getAuthor().get('avatar_url'))

  canViewerEdit: ->
    @props.cursor.viewer.get('uuid') == @getLanding().get('author_id')

  update: (attributes) ->
    LandingSyncApi.update(@getLanding(), attributes.toJSON())

  isDisabled: ->
    @canViewerEdit && UserStore.isEditor()

  getLoginLink: ->
    return null if @isDisabled()
    Constants.TWITTER_AUTH_PATH

  getMainPageLink: ->
    return null if @isDisabled()
    '/'


  # Handlers
  #
  handleAvatarChange: (file) ->
    newAttributes = @state.attributes.withMutations (attributes) ->
      attributes.set('image', file).set('image_url', URL.createObjectURL(file))

    @setState(attributes: newAttributes)
    @update(newAttributes)

  handleBodyChange: (value) ->
    newAttributes = @state.attributes.set('body', value)

    @setState(newAttributes)
    @update(newAttributes)


  # Lifecycle methods
  #
  componentWillMount: ->
    @fetch()


  # Renderers
  #
  renderImage: ->
    <PersonAvatar
      avatarURL  =  { @state.attributes.get('image_url') }
      onChange   =  { @handleAvatarChange }
      readOnly   =  { !@canViewerEdit() }
      value      =  { @getAuthor().get('full_name') }
      withCamera =  { true } />

  renderBody: ->
    <ContentEditableArea
      onChange    = { @handleBodyChange }
      placeholder = "Tap to add message"
      readOnly    = { !@canViewerEdit() }
      value       = { @state.attributes.get('body') } />

  renderUserLoginControls: ->
    <section className="login-controls">
      <a className = { cx(cc: true, disabled: @isDisabled()) } href={ @getLoginLink() }>
        Sign in with Twitter
      </a>
      <a className = { cx(disabled: @isDisabled()) } href={ @getMainPageLink() }>
        Skip to the main page
      </a>
    </section>

  renderReturnLink: ->
    return null unless UserStore.isEditor()

    <a className="cc" href={ @getUser().get('user_url') + '#settings' }>
      Return to { @getUser().get('full_name') } profile
    </a>

  render: ->
    return null unless @isLoaded()

    <section className="custom-landing">
      <section className="message">
        { @renderImage() }
        { @renderBody() }
      </section>
      { @renderUserLoginControls() }
      { @renderReturnLink() }
    </section>
