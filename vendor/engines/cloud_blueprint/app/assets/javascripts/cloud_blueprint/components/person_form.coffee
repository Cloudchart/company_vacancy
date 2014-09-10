##= require cloud_blueprint/components/inputs/date_input.module
##= require actions/person_actions_creator.module
##= require utils/person_sync_api.module
##= require stores/PersonStore
##= require cloud_blueprint/actions/modal_window_actions_creator.module

# Imports
#
tag = React.DOM


# Date Input Component
#
InputComponent              = require('cloud_blueprint/components/inputs/input')
DateInputComponent          = require('cloud_blueprint/components/inputs/date_input')
PercentageInputComponent    = require('cloud_blueprint/components/inputs/percentage_input')

PersonActionsCreator        = require('actions/person_actions_creator')
ModalWindowActionsCreator   = require('cloud_blueprint/actions/modal_window_actions_creator')
PersonSyncAPI               = require('utils/person_sync_api')

PersonStore                 = cc.require('cc.stores.PersonStore')
NodeIdentityStore           = require('cloud_blueprint/stores/node_identity_store')
NodeIdentityActions         = require('cloud_blueprint/actions/node_identity_actions')


percentage_re = /^[0-9]+([\.\,][0-9]+){0,1}$/


# Known Attributes
#
KnownAttributes = [PersonStore.unique_key, 'full_name', 'email', 'occupation', 'phone', 'int_phone', 'skype', 'birthday', 'hired_on', 'fired_on', 'salary', 'stock_options', 'bio']

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
  
  {
    name:         'stock_options'
    icon:         'bar-chart-o'
    type:         'percentage'
    placeholder:  'Stock options'
  }
  
]


# Functions
#
getStateFromStores = (props) ->
  attributes = filterAttributes(props.model.attr())
  _.extend attributes,
    identity: NodeIdentityStore.find(props.identity.to_param()) if props.identity


filterAttributes = (attributes = {}) ->
  _.reduce attributes, (memo, value, name) =>
    memo[name] = value if _.contains(KnownAttributes, name) ; memo
  , {}


# Main Component
#
Component = React.createClass


  isValid: ->
    @state['full_name'] and @state['full_name'].trim().length > 0


  update: ->
    PersonActionsCreator.update(@props.model.to_param(), filterAttributes(@state), true) if @props.model.to_param()
    @setState({ shouldUpdate: false })
  
  
  onCreateButtonClick: ->
    PersonActionsCreator.create(@props.company_id, @props.model, filterAttributes(@state))
  
  
  onNameChange: (event) ->
    @setState({ full_name: event.target.value })
  
  
  onDateChange: (field_name, value) ->
    state             = { shouldUpdate: true }
    state[field_name] = value
    @setState(state)
  
  
  onPercentageChange: (field, event) ->
    value = event.target.value
    state = {}

    # { parsedValue, valueIsValid } = parsePercentageValue(value)
    parsedValue = parseFloat(value)
    valid       = value.length == 0 or (percentage_re.test(value) and parsedValue >= 0 and parsedValue <= 100)
    
    state["#{field.name}_is_valid"] = valid
    state[field.name]               = value

    @setState(state)
  
  
  onPercentageBlur: (field, event) ->
    value       = event.target.value
    state       = {}

    parsedValue = parseFloat(value) || ''
    valid       = value.length == 0 or (percentage_re.test(value) and parsedValue >= 0 and parsedValue <= 100)
    
    state["#{field.name}_is_valid"] = true

    if valid
      state[field.name]     = parsedValue
      state['shouldUpdate'] = parsedValue != @props.model.attr(field.name)
    else
      state[field.name] = @props.model.attr(field.name) || ''
    
    @setState(state)
    
  
  
  onFieldBlur: (field_name, event) ->
    state             = { shouldUpdate: true }
    state[field_name] = event.target.value
    @setState(state)
  
  
  gatherFields: ->
    _.map FormFields, (field) =>
      
      (tag.label {
        key:        field.name
        className:  field.name
      },
      
        (tag.i { className: "fa fa-#{field.icon}"}) if field.icon
          
        switch field.type
          
          when 'date'
            (DateInputComponent {
              date:         @state[field.name]
              placeholder:  field.placeholder
              onChange:     @onDateChange.bind(@, field.name)
            })
          when 'percentage'
            (tag.input {
              className:  'invalid' if @state["#{field.name}_is_valid"] == false
              type:       'text'
              value:      @state[field.name]
              onChange:   @onPercentageChange.bind(@, field)
              onBlur:     @onPercentageBlur.bind(@, field)
            })
          else
            (InputComponent {
              value:        @state[field.name]
              placeholder:  field.placeholder
              onBlur:       @onFieldBlur.bind(@, field.name)
            })
      )
  
  
  refreshStateFromStores: ->
    @setState getStateFromStores(@props)


  componentDidMount: ->
    PersonStore.on('change', @refreshStateFromStores)
    NodeIdentityStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnmount: ->
    PersonStore.off('change', @refreshStateFromStores)
    NodeIdentityStore.off('change', @refreshStateFromStores)
  
  
  componentDidUpdate: ->
    @update() if @state.shouldUpdate
  
  
  componentWillReceiveProps: (nextProps) ->
    @setState getStateFromStores(nextProps)


  getInitialState: ->
    getStateFromStores(@props)


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
          (InputComponent {
            value:        @state['full_name']
            placeholder:  'Name Surname'
            onChange:     @onNameChange unless @props.model.to_param()
            onBlur:       @onFieldBlur.bind(@, 'full_name')
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
            defaultValue: @state['bio']
            placeholder:  'Bio'
            onBlur:       @onFieldBlur.bind(@, 'bio')
          })
        )

      )

      # Buttons
      #
      (tag.footer {
      },
        
        
        (tag.button {
          className:  'blueprint alert'
          type:       'button'
          onClick:    NodeIdentityActions.destroy.bind(null, @state.identity)
        },
          'Remove from Group'
          (tag.i { className: 'fa fa-times' })
        ) if @state.identity
        
        
        (tag.div { className: 'spacer' })
        
        (tag.button {
          className:  'blueprint'
          type:       'button'
          onClick:    ModalWindowActionsCreator.close
        },
          'Close'
          (tag.i { className: 'fa fa-check' })
        ) if @props.model.to_param()
        
        
        (tag.button {
          className:  'blueprint'
          type:       'button'
          disabled:   !@isValid()
          onClick:    @onCreateButtonClick
        },
          'Create'
          (tag.i { className: 'fa fa-check' })
        ) unless @props.model.to_param()
      
      )

    )


# Exports
#
cc.module('cc.blueprint.components.PersonForm').exports = Component
