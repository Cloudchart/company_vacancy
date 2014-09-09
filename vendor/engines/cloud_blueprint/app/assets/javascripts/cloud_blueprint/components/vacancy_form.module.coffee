# Imports
#
tag = React.DOM


ModalWindowActions  = require('cloud_blueprint/actions/modal_window_actions_creator')

VacancyStore    = require('stores/vacancy_store')
VacancyActions  = require('actions/vacancy_actions')


knownAttributes = ['name', 'description']


filterAttributes = (attributes = {}) ->
  _.reduce knownAttributes, (memo, name) ->
    memo[name] = attributes[name]
    memo
  , {}
  


# Main Component
#
Component = React.createClass


  mixins: [
    React.addons.LinkedStateMixin
  ]


  create: ->
    VacancyActions.create(@props.model, filterAttributes(@state))
  

  update: ->
    VacancyActions.update(@props.model, filterAttributes(@state))
  
  
  getStateFromModel: (model) ->
    filterAttributes(model.attr())
  
  
  onCreateButtonClick: ->
    @create()
  
  
  onFieldBlur: (name, event) ->
    @update() if @props.model.to_param()
  
  
  onStoreChange: ->
    @setState @getStateFromModel(@props.model)


  componentDidMount: ->
    VacancyStore.on('change', @onStoreChange)
  
  
  componentWillUnmount: ->
    VacancyStore.off('change', @onStoreChange)
  
  
  componentWillReceiveProps: (nextProps) ->
    @setState @getStateFromModel(nextProps.model)
  
  
  getInitialState: ->
    @getStateFromModel(@props.model)


  render: ->
    (tag.form {
      className: 'vacancy'
      onSubmit: (event) -> event.preventDefault()
    },
      # Fields
      #
      (tag.section {
        className: 'fields'
      },
      
        # Avatar
        #
        (tag.aside {
          className: 'avatar'
        },
          (tag.i { className: 'fa fa-briefcase' })
        )
        
        # Name
        #
        (tag.label {
          className: 'name'
        },
          (tag.input {
            valueLink:    @linkState('name')
            placeholder:  'Name'
            onBlur:       @onFieldBlur.bind(@, 'name')
          })
        )
        
        # Description
        #
        (tag.label {
          className: 'description'
        },
          
          (tag.i { className: 'fa fa-file-text-o' })
        
          (tag.textarea {
            valueLink:    @linkState('description')
            placeholder:  'Description'
            onBlur:       @onFieldBlur.bind(@, 'description')
          })
        )
        
      
      )
      

      # Buttons
      #
      (tag.footer {
        className: 'buttons'
      },

        # Spacer
        #
        (tag.div { className: 'spacer' })
          
        
        # Create button
        #
        (tag.button {
          className:  'blueprint'
          type:       'button'
          onClick:    @onCreateButtonClick
          disabled:   !!@state.creating
        },
        
          'Create'
          
          if !@state.creating
            (tag.i { className: 'fa fa-check' })
          else
            (tag.i { className: 'fa fa-spinner fa-spin' })
        
        ) unless @props.model.to_param()
        
          
        # Close button
        #
        (tag.button {
          className:  'blueprint'
          type:       'button'
          onClick:    ModalWindowActions.close
        },
          'Close'
          (tag.i { className: 'fa fa-check' })
        ) if @props.model.to_param()
        
      )
    )


# Exports
#
module.exports = Component
