# Imports
# 
tag = React.DOM

QueryInputComponent   = cc.require('cc.components.QueryInput')
PersonComponent = cc.require('cc.components.Person')

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

  # Instance Methods
  # 
  gatherControls: ->
    switch @state.mode
    
      when 'edit'
        [
          (QueryInputComponent {
            key:          'query-input'
            placeholder:  'Type name'
            autoFocus:    true
            onChange:     @onQueryChange
            onCancel:     @onQueryCancel
          })

          @gatherPeople()
        ]
      
      when 'view'
        @addButton()

  gatherPeople: ->
    (tag.ul { key: 'people-list', className: 'identity-list' },
      # _.chain
      (tag.li { 
        className: 'identity' 
        onClick: @onPersonClick
      }, 
        (PersonComponent { key: 'e23dc502-6922-4465-b59c-79cdb9720eb5' })
      )
    )

  addButton: ->
    (tag.button {
      key:      'add-button'
      onClick:  @onAddButtonClick
    },
      "Add"
      (tag.i { className: 'fa fa-male' })
    )

  # Events
  # 
  onPersonClick: ->
    # change owners collection
    @setState
      mode: 'view'

  onAddButtonClick: ->
    @setState
      mode: 'edit'

  onQueryChange: (query) ->
    @setState
      query: query
  
  onQueryCancel: ->
    @setState
      query:  []
      mode:   'view'  

# Exports
#
cc.module('react/company/owners/selector').exports = MainComponent
