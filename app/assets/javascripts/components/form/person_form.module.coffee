# Imports
#
tag = React.DOM

PersonActions = require('actions/person_actions')
PersonStore   = require('stores/person')
PersonAvatar  = require('components/shared/person_avatar')

Header = ->
  (tag.header {
  },
    (tag.input {
      autoFocus:    true
      onChange:     @onFieldChange.bind(@, 'full_name')
      value:        @state.attributes.get('full_name')
      placeholder:  "Name Surname"
    })
  )


Fieldset = ->
  now = moment().format('ll')
  (tag.fieldset {
  },
    Field.apply(@,  ['email',          'fa-envelope-o',    'user@example.com'])
    Field.apply(@,  ['twitter',        'fa-twitter',       '@handle'])
    Field.apply(@,  ['occupation',     'fa-institution',   'Occupation'])
    #Field.apply(@,  ['phone',          'fa-mobile',        'Mobile phone'])
    #Field.apply(@,  ['int_phone',      'fa-phone',         'Office phone'])
    #Field.apply(@,  ['skype',          'fa-skype',         'Skype name'])
    #Field.apply(@,  ['birthday',       'fa-birthday-cake', now])
    dateField.apply(@,  ['hired_on',       'fa-sign-in',       now])
    dateField.apply(@,  ['fired_on',       'fa-sign-out',      now])
    #Field.apply(@,  ['salary',         'fa-money',         '0.0'])
    #Field.apply(@,  ['stock_options',  'fa-bar-chart',     '0.0'])
    #Text.apply(@,   ['bio',            'fa-file-text-o',   'Bio'])
  )


Field = (name, icon, placeholder) ->
  (tag.label {
    className: name
  },
    (tag.i { className: "fa #{icon}" })
    (tag.input {
      value:        @state.attributes.get(name)
      onChange:     @onFieldChange.bind(@, name)
      placeholder:  placeholder
    })
  )

dateField = (name, icon, placeholder) ->
  (tag.label {
    className: name
  },
    (tag.i { className: "fa #{icon}" })
    (tag.input {
      value:        @state.attributes.get(name)
      onChange:     @onFieldChange.bind(@, name)
      onBlur:       @onDateBlur.bind(@, name)
      placeholder:  placeholder
    })
  )


Text = (name, icon, placeholder) ->
  (tag.label {
    className: name
  },
    (tag.i { className: "fa #{icon}" })
    (tag.textarea {
      value:        @state.attributes.get(name)
      onChange:     @onFieldChange.bind(@, name)
      placeholder:  placeholder
    })
  )


# Main
#
Component = React.createClass


  isValid: ->
    @state.attributes.get('full_name').length > 0


  onDateBlur: (name) ->
    date = Date.parse(@state.attributes.get(name))
    if moment(date).isValid()
      @setState({ attributes: @state.attributes.set(name, moment(date).format('ll')) })


  onAvatarChange: (file) ->
    @setState
      attributes: @state.attributes.withMutations (attributes) ->
        attributes.remove('remove_avatar').set('avatar', file).set('avatar_url', URL.createObjectURL(file))


  onAvatarRemove: ->
    @setState
      attributes: @state.attributes.withMutations (attributes) ->
        attributes.remove('avatar').remove('avatar_url').set('remove_avatar', true)


  onFieldChange: (name, value) ->
    value = event.target.value
    @setState({ attributes: @state.attributes.set(name, value) })

  # need to put it into separate controller later
  onSubmit: (event) ->
    event.preventDefault()

    person = PersonStore.get(@props.uuid)

    if person.uuid
      PersonActions.update(@props.uuid, @state.attributes.toJSON())
    else
      PersonActions.create(@props.uuid, @state.attributes.toJSON())

    @props.onSubmit()

  getAttributes: (props) ->
    attributes = props.attributes

    # date typecast
    # TODO: move to base logic
    _.each ['hired_on', 'fired_on'], (name) ->
      now = moment(Date.parse(attributes[name]))
      attributes[name] = now.format('ll') if now.isValid()

    attributes: Immutable.fromJS(attributes)


  componentWillReceiveProps: (nextProps) ->
    @setState(@getAttributes(nextProps))

  getDefaultProps: ->
    onSubmit: ->

  getInitialState: ->
    @getAttributes(@props)


  render: ->
    (tag.form {
      onSubmit:   @onSubmit
      className:  'person-2'
    },

      # Header
      #
      Header.apply(@)

      #
      #
      (tag.section {
      },

        # Avatar
        #
        #(tag.aside {
        #  className: 'avatar'
        #})
        PersonAvatar({
          avatarURL:  @state.attributes.get('avatar_url')
          onChange:   @onAvatarChange
          onRemove:   @onAvatarRemove
          value:      @state.attributes.get('full_name')
        })

        # Fields
        #
        Fieldset.apply(@)

      )

      # Footer
      #
      (tag.footer {
      },

        # Spacer
        #
        (tag.div { className: 'spacer' })

        # Submit
        #
        (tag.button {
          className:  'cc'
          disabled:   !@isValid()
          type:       'submit'
        },
          if @state.attributes.get('uuid') then "Update" else "Create"
          (tag.i { className: 'fa fa-check' })
        )
      )

    )


# Exports
#
module.exports = Component
