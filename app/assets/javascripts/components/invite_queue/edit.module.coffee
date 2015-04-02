# @cjsx React.DOM


GlobalState = require('global_state/state')


# Components
#
HeaderComponent = require('components/invite_queue/header')


# Fields
#
Fields = Immutable.Seq [
  {
    name: 'full_name'
    placeholder: 'Name Surname'
  }

  {
    name: 'company'
    placeholder: 'Company'
  }

  {
    name: 'occupation'
    placeholder: 'Job Title'
  }

  {
    name: 'email'
    placeholder: 'Email'
  }
]


# Update
#
update = (attributes = {}) ->
  Promise.resolve $.ajax
    url:        '/auth/queue'
    type:       'PUT'
    dataType:   'json'
    data:       attributes



# Exports
#
module.exports = React.createClass


  handleSubmit: (event) ->
    event.preventDefault()

    update(@state.attributes.toJS())
      .then (json) =>
        GlobalState.fetch(new GlobalState.query.Query("User{tokens}"), { id: @props.user.uuid, force: true })
          .then =>
            @props.onChange() if typeof @props.onChange is 'function'

      .catch (xhr) =>
        @setState
          errors: Immutable.List(xhr.responseJSON.errors)



  handleChange: (name, event) ->
    @setState
      attributes: @state.attributes.set(name, event.target.value)
      errors:     @state.errors.remove(@state.errors.indexOf(name))


  getAttributesFromProps: (props) ->
    Immutable.OrderedMap({}).withMutations (attributes) ->
      Fields.forEach (field) ->
        attributes.set(field.name, props.user[field.name] || '')


  getInitialState: ->
    attributes: @getAttributesFromProps(@props)
    errors:     Immutable.List()


  gatherFields: ->
    Fields.map (field) =>
      <input
        className   = { if @state.errors.contains(field.name) then 'error' else null }
        type        = "text"
        key         = { field.name }
        placeholder = { field.placeholder}
        value       = { @state.attributes.get(field.name) }
        onChange    = { @handleChange.bind(@, field.name) }
      />


  renderForm: ->
    <form onSubmit={ @handleSubmit }>
      <fieldset>
        { @gatherFields().toArray() }
      </fieldset>

      <button className="cc">
        { "I want my invite!" }
      </button>
    </form>


  render: ->
    <section className="invite-queue">
      <HeaderComponent user = { @props.user } />
      { @renderForm() }
    </section>
