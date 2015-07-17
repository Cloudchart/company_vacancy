# Imports
#
tag = React.DOM


CloudFlux       = require('cloud_flux')


VacancyStore    = require('stores/vacancy')
VacancyActions  = require('actions/vacancy')


isValidated = (attributes) ->
  attributes.get('name').length > 0


# Main
#
Component = React.createClass


  mixins: [CloudFlux.mixins.Actions]
  
  
  onCreateDone: (uuid) ->
    @props.onCreate() if uuid is @props.uuid and _.isFunction(@props.onCreate)
  
  
  onUpdateDone: (uuid) ->
    @props.onUpdate() if uuid is @props.uuid and _.isFunction(@props.onUpdate)
  
  
  getCloudFluxActions: ->
    'vacancy:create:done-': @onCreateDone
    'vacancy:update:done-': @onUpdateDone


  onSubmit: (event) ->
    event.preventDefault()
    
    return if VacancyStore.getSync(@props.uuid)
    
    if @state.attributes.get('uuid')
      VacancyActions.update(@props.uuid, @state.attributes.toJSON())
    else
      VacancyActions.create(@props.uuid, @state.attributes.toJSON())


  onFieldChange: (name, event) ->
    @props.onChange(event) if _.isFunction(@props.onChange)
    
    value = event.target.value

    @setState({ attributes: @state.attributes.set(name, value) })
  
  
  componentDidMount: ->
    VacancyStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnmount: ->
    VacancyStore.off('change', @refreshStateFromStores)
  
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  
  getStateFromStores: ->
    attributes: VacancyStore.get(@props.uuid).toMap()
  
  
  getInitialState: ->
    @getStateFromStores()


  render: ->
    sync = VacancyStore.getSync(@props.uuid)

    (tag.form {
      className:  'vacancy'
      onSubmit:   @onSubmit
    },
    
      # Header
      #
      (tag.header {
      },
        
        # Back link
        #
        @props.backLinkComponent
        
        # Name input
        #
        (tag.input {
          autoFocus:    true
          onChange:     @onFieldChange.bind(@, 'name')
          placeholder:  'Name your vacancy'
          value:        @state.attributes.get('name')
        })
        
      )
      
      
      # Fields and Logo
      #
      (tag.section {
      },
      
        # Logo
        #
        (tag.aside {
        },
          (tag.i { className: 'fa fa-briefcase' })
        )
        
        # Fields
        #
        (tag.fieldset {
        },
          
          # Description
          (tag.textarea {
            onChange:     @onFieldChange.bind(@, 'description')
            placeholder:  'Describe your vacancy'
            value:        @state.attributes.get('description')
          })
        
        )
        
      )
      
      
      # Footer
      #
      (tag.footer {
      },
        (tag.div { className: 'spacer' })
          
        # Create button
        #
        (tag.button {
          className:  'cc'
          disabled:   !isValidated(@state.attributes) or sync
        },
          "Create"
          (tag.i { className: 'fa fa-check' }) unless sync == 'create'
          (tag.i { className: 'fa fa-spin fa-spinner' }) if sync == 'create'
        ) unless @state.attributes.get('uuid')
      )
    
    )

# Exports
#
module.exports = Component
