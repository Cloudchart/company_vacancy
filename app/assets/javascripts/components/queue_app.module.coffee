# @cjsx React.DOM


# Imports
#
GlobalState = require('global_state/state')
CloudRelay  = require('cloud_relay')


# Stores
#
UserStore   = require('stores/user_store.cursor')
TokenStore  = require('stores/token_store.cursor')


# Update
#
update = (attributes = {}) ->
  Promise.resolve $.ajax
    url:        '/auth/queue'
    type:       'PUT'
    dataType:   'json'
    data:       attributes


findEmailVerificationTokenFor = (user_id) ->
  TokenStore.cursor.items.find (token) ->
    token.get('owner_type') == 'User' and
    token.get('owner_id') == user_id and
    token.get('name') == 'email_verification'


# Fields
#
Fields = Immutable.Seq({ full_name: 'Name Surname', company: 'Company', occupation: 'Occupation', email: 'Email' })


# Main Component
#
MainComponent = React.createClass

  displayName: 'InviteQueueApp'


  mixins: [GlobalState.mixin]


  handleSubmit: (event) ->
    event.preventDefault()


  handleChange: (name, event) ->
    @setState
      attributes: @state.attributes.set(name, event.target.value)


  onGlobalStateChange: ->
    @setState
      attributes: @getAttributesFromCursor()



  componentWillMount: ->
    @cursor =
      user:     UserStore.cursor.items.cursor(@props.user)
      tokens:   TokenStore.cursor.items



  getAttributesFromCursor: ->
    user = if @cursor then @cursor.user else Immutable.Map()
    Immutable.Map().withMutations (data) ->
      Fields.forEach (__, name) ->
        if name == 'email'
          if token = findEmailVerificationTokenFor(user.get('uuid'))
            data.set(name, token.getIn(['data', 'address']))
        else
          data.set(name, user.get(name, ''))



  getInitialState: ->
    attributes: @getAttributesFromCursor()
    errors:     []
    pending:    false


  renderHeader: ->
    <header>
      { "Hello stranger," }
      <br />
      { "Welcome to the CloudChart invite queue. Yes, we're popular." }
      <br />
      { "If you, like us, rather act than wait, tell us a bit more about yourself. The more we know, the faster we wrap and send you that invite." }
    </header>


  renderFields: ->
    fields = Fields.map (placeholder, name) =>
      <label key={ name } style={ display: 'block', margin: '10px 0' }>
        <input
          autoFocus   = { name == 'full_name' }
          value       = { @state.attributes.get(name) }
          placeholder = { placeholder }
          onChange    = { @handleChange.bind(@, name) }
          style       = { backgroundColor: if @state.errors.indexOf(name) > -1 then '#fcc' else '#fff' }
        />
      </label>

    <fieldset style={ border: 0, margin: 0, padding: 0 }>
      { fields.toArray() }
    </fieldset>


  renderButton: ->
    <button>
      I want my invite!
    </button>


  render: ->
    <form onSubmit={@handleSubmit}>
      { @renderHeader() }

      <section>
        <aside style={ border: '1px solid #ccc', borderRadius: '50%', margin: '10px 0', width: 100, height: 100 }>
          <figure
            style = {
              backgroundImage: if url = @cursor.user.get('avatar_url') then "url(#{url})" else "none"
              backgroundSize: 'cover'
              width: '100%'
              height: '100%'
            }
          />
        </aside>
        { @renderFields() }
      </section>

      <footer>
        { @renderButton() }
      </footer>
    </form>


# Exports
#
module.exports = CloudRelay.createContainer MainComponent,

  queries:

    user: ->
      """
        User {
          tokens
        }
      """
