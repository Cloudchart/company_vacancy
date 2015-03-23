# @cjsx React.DOM


# Imports
#
GlobalState = require('global_state/state')


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


# Exports
#
module.exports = React.createClass

  displayName: 'Invite Queue App Component'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    queries:

      user: ->
        """
          User {
            tokens
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('user'), { id: @props.user, force: true })


  handleSubmit: (event) ->
    event.preventDefault()
    @setState
      errors:   []
      pending:  true

    update(@state.attributes.toJSON())
      .then =>
        @fetch()
        @setState
          pending: false
      .catch (xhr) =>
        @setState
          attributes: @getAttributesFromCursor()
          errors:     xhr.responseJSON.errors
          pending:    false


  handleChange: (name, event) ->
    @setState
      attributes: @state.attributes.set(name, event.target.value)


  onGlobalStateChange: ->
    @setState
      attributes: @getAttributesFromCursor()



  componentWillMount: ->
    @cursor =
      user: UserStore.cursor.items.cursor(@props.user)

    @fetch()



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
    title = if @state.pending then "Saving..." else "Save"
    icon  = if @state.pending then "fa-spin fa-spinner" else "fa-check"
    <button>
      { title }
      <i className="fa #{icon}" style={ marginLeft: 5 } />
    </button>


  render: ->
    <form onSubmit={@handleSubmit}>
      <header>
        Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
      </header>

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
