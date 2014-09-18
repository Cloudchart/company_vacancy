# deprecated
# 

##= require components/QueryInput
##= require components/Person
##= require components/IdentityList
##= require stores/PersonStore

# Imports
# 
tag = React.DOM
email_re = /.+@.+\..+/i

QueryInputComponent = cc.require('cc.components.QueryInput')
PersonComponent = cc.require('cc.components.Person')
IdentityListComponent = cc.require('cc.components.IdentityList')
PersonStore = cc.require('cc.stores.PersonStore')

# Main Component
#
MainComponent = React.createClass

  # Component Specifications
  #
  render: ->
    (tag.div { className: 'identity-selector aspect-ratio-1x1' },
      (tag.div { className: 'content' },
        @gatherControls()
      )
    )

  getInitialState: ->
    mode: 'view'
    query: []
    email: []
    error: false

  # getDefaultProps: ->

  # Lifecycle Methods
  #
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->

  # Helpers
  # 
  gatherControls: ->
    switch @state.mode
    
      when 'select'
        [
          (QueryInputComponent {
            key:          'query-input'
            placeholder:  'Type name'
            autoFocus:    true
            onChange:     @onQueryChange
            onCancel:     @onQueryCancel
          })

          (IdentityListComponent {
            key:            'people-list'
            onSelect:       @onPersonSelect
          },
            @gatherPeople()
          )

        ]
      
      when 'email'
        [
          (tag.input {
            key: 'email-input'
            className: 'error' if @state.error
            placeholder: 'Type email'
            autoFocus: true
            onChange: @onEmailChange
            onKeyUp: @onEmailKeyUp
          })

          (tag.header { key: 'email-header' }, @state.person_for_email.attr('full_name'))
        ]

      when 'view'
        @addButton()

  gatherPeople: ->
    people = _.chain(PersonStore.all())
      .reject (person) => _.contains(@props.filtered_people, person.to_param())
      .filter (person) => _.all @state.query, (q) -> person.matches(q)
      .sortBy (person) -> person.sortValue()
      .value()

    _.map people, (person) ->
      (PersonComponent { key: person.to_param() })

  addButton: ->
    (tag.button {
      key:      'add-button'
      onClick:  @onAddButtonClick
    },
      "Add"
      (tag.i { className: 'fa fa-male' })
    )

  isEmailValid: ->
    email_re.test(@state.email)

  # Events
  # 
  onEmailKeyUp: (event) ->
    switch event.key
      when 'Enter'
        @inviteOwner(@state.person_for_email.to_param(), @state.email) if @isEmailValid()
      when 'Escape'
        @setState
          email: []
          mode: 'select'

  onPersonSelect: (key) ->
    person = PersonStore.find(key)

    if person.attr('user_id')
      @makeOwner(key)
    else if person.attr('email')
      @inviteOwner(key)
    else
      @setState
        mode: 'email'
        person_for_email: person

  onAddButtonClick: ->
    @setState
      mode: 'select'

  onQueryChange: (query) ->
    @setState
      query: query
  
  onQueryCancel: ->
    @setState
      query:  []
      mode:   'view'  

  onEmailChange: (event) ->
    @setState
      email: event.target.value

  # Ajax
  # 
  makeOwner: (key) ->
    $.ajax
      url: "/people/#{key}/make_owner"
      method: 'PUT'
      dataType: 'json'
    .done @onMakeOwnerDone
    .fail @onMakeOwnerFail
        
  onMakeOwnerDone: (json) ->
    @props.onChange({ target: { value: json } })
    @setState
      mode: 'view'

  onMakeOwnerFail: ->
    console.warn 'onMakeOwnerFail'

  inviteOwner: (key, email=null) ->
    @setState({ error: false })

    $.ajax
      url: '/company_invites'
      method: 'POST'
      dataType: 'json'
      data:
        email: email
        person_id: key
        make_owner: true
    .done @onInviteOwnerDone
    .fail @onInviteOwnerFail    

  onInviteOwnerDone: (json) ->
    @props.onChange({ target: { value: json } })
    @setState
      mode: 'view'

  onInviteOwnerFail: (json) ->
    # console.warn json.responseText
    @setState
      error: true

# Exports
#
cc.module('react/company/settings/owner_selector').exports = MainComponent
