##= require cloud_blueprint/components/inputs/date_input.module
##= require actions/person_actions_creator.module
##= require utils/person_sync_api.module
##= require stores/PersonStore

# Imports
#
tag = React.DOM


# Date Input Component
#
DateInputComponent    = require('cloud_blueprint/components/inputs/date_input')
PersonActionsCreator  = require('actions/person_actions_creator')
PersonSyncAPI         = require('utils/person_sync_api')

PersonStore           = cc.require('cc.stores.PersonStore')


# Known Attributes
#
KnownAttributes = [PersonStore.unique_key, 'full_name', 'email', 'occupation', 'phone', 'int_phone', 'skype', 'birthday', 'hired_on', 'fired_on', 'salary']

# Form fields
#
FormFields = [
  
  {
    name:         'occupation'
    icon:         'institution'
    type:         'text'
    placeholder:  'Occupation'
  }
  
  {
    name:         'email'
    icon:         'envelope-o'
    type:         'email'
    placeholder:  'Email'
  }

  {
    name:         'phone'
    icon:         'mobile'
    type:         'tel'
    placeholder:  'Phone'
  }
  
  {
    name:         'int_phone'
    icon:         'phone'
    type:         'tel'
    placeholder:  'Office Phone'
  }
  
  {
    name:         'skype'
    icon:         'skype'
    type:         'text'
    placeholder:  'Skype'
  }
  
  {
    name:         'birthday'
    icon:         'beer'
    type:         'date'
    placeholder:  'Birthday'
  }
  
  {
    name:         'hired_on'
    icon:         'sign-in'
    type:         'date'
    placeholder:  'Hired on'
  }
  
  {
    name:         'fired_on'
    icon:         'sign-out'
    type:         'date'
    placeholder:  'Fired on'
  }
  
  {
    name:         'salary'
    icon:         'money'
    type:         'text'
    placeholder:  'Salary'
  }
  
]


# Functions
#
getStateFromStores = (key) ->
  if model = PersonStore.find(key) then filterAttributes(model.attr()) else {}


filterAttributes = (attributes = {}) ->
  _.reduce attributes, (memo, value, name) =>
    memo[name] = value if _.contains(KnownAttributes, name) ; memo
  , {}


# Main Component
#
Component = React.createClass


  mixins: [
    React.addons.LinkedStateMixin
  ]
  
  
  update: ->
    PersonActionsCreator.update(@props.key, filterAttributes(@state), true)
    @setState({ shouldUpdate: false })
  
  
  onDateChange: (field_name, value) ->
    data              = {}
    data[field_name]  = value
    @setState(data)
    @setState({ shouldUpdate: true })
  
  
  onFieldBlur: (field_name) ->
    @setState({ shouldUpdate: true })
  
  
  onCloseButtonClick: ->
    
  
  
  gatherFields: ->
    _.map FormFields, (field) =>
      
      (tag.label {
        key:        field.name
        className:  field.name
      },
      
        (tag.i { className: "fa fa-#{field.icon}"}) if field.icon
      
        if field.type == 'date'
          (DateInputComponent {
            date:         @state[field.name]
            placeholder:  field.placeholder
            onChange:     @onDateChange.bind(@, field.name)
          })
        else
          (tag.input {
            type:         field.type
            valueLink:    @linkState(field.name)
            placeholder:  field.placeholder
            onBlur:       @onFieldBlur.bind(@, field.name)
          })
      )
  
  
  refreshStateFromStores: ->
    @setState getStateFromStores(@props.key)


  componentWillMount: ->
    unless @state[PersonStore.unique_key]
      PersonSyncAPI.fetch("/people/#{@props.key}")
  

  componentDidMount: ->
    PersonStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnmount: ->
    PersonStore.off('change', @refreshStateFromStores)
  
  
  componentDidUpdate: ->
    @update() if @state.shouldUpdate


  getInitialState: ->
    getStateFromStores(@props.key)


  render: ->
    (tag.form {
      className: 'person'
    },

      # Form Content
      #
      (tag.section {
        className: 'fields'
      },
      
        # Avatar
        #
        (tag.aside {
          className: 'avatar'
        })
      
        # Full name
        #
        (tag.label {
          className: 'full-name'
        },
          (tag.input {
            type:         'text'
            valueLink:    @linkState('full_name')
            placeholder:  'Name Surname'
          })
        )

        # Fields
        #
        @gatherFields()
        
        # Bio
        #
        (tag.label {
          className: 'bio'
        },
        
          (tag.i { className: 'fa fa-file-text-o' })
        
          (tag.textarea {
            valueLink:    @linkState('bio')
            placeholder:  'Bio'
          })
        )

      )

      # Buttons
      #
      (tag.footer {
      },
        
        (tag.div { className: 'spacer' })
        
        (tag.button {
          className:  'blueprint'
          type:       'button'
          onClick:    @onCloseButtonClick
        },
          'Close'
          (tag.i { className: 'fa fa-check' })
        )
      
      )

    )


# Exports
#
cc.module('cc.blueprint.components.PersonForm').exports = Component
