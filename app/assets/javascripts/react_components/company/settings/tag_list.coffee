##= require ../../../plugins/react_tokeninput/main
##= require ../../../plugins/react_tokeninput/option

# Imports
# 
tag = React.DOM

TokenInput = cc.require('plugins/react_tokeninput/main')
ComboboxOption = cc.require('plugins/react_tokeninput/option')

# Main Component
# 
MainComponent = React.createClass

  # Helpers
  # 
  gatherComboboxOptions: ->
    selected_ids = _.pluck(@state.selected, 'id')
    filtered_options = _.filter(@state.options, (tag) -> !_.contains(selected_ids, tag.id))

    _.map filtered_options, (tag) ->
      (ComboboxOption { key: tag.id, value: tag }, tag.name)

  save: ->
    selected_names = _.map(@state.selected, (tag) -> tag.name).join(', ')
    @props.onChange({ target: { value: selected_names, options: @state.options } })

  # Events
  # 
  onChange: (event) ->
    @setState({ selected: event.target.value })

  onInput: (query) ->
    if query == ''
      @setState({ options: @props.options })
    else
      query_re = new RegExp(query, 'i')
      filtered_options = _.filter @props.options, (tag) -> query_re.test(tag.name)
      @setState({ options: filtered_options })

  onSelect: (value) ->
    @setState
      selected: _.union(@state.selected, [value])
      should_save: true

  onRemove: (value) ->
    @setState
      selected: _.pull(@state.selected, value)
      should_save: true

  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  componentWillReceiveProps: (nextProps) ->
    @setState({ should_save: false })
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  componentDidUpdate: (prevProps, prevState) ->
    @save() if @state.should_save
    
  # componentWillUnmount: ->

  # Component Specifications
  # 
  # getDefaultProps: ->
  getInitialState: ->
    selected: @props.selected || []
    options: @props.options || []
    should_save: false

  render: ->
    # (tag.div { className: 'profile-item' },
    (tag.div {},

      (TokenInput {
        onChange: @onChange
        onInput: @onInput
        onSelect: @onSelect
        onRemove: @onRemove
        selected: @state.selected
        menuContent: @gatherComboboxOptions()
      })      
      # (tag.div { className: 'content field' },
        # (tag.label { htmlFor: 'tag_list' }, 'Tags')

        # (tag.div { className: 'spacer' })

        # (tag.input {
        #   id: 'tag_list'
        #   name: 'tag_list'
        #   placeholder: 'russia, entertainment, games'
        #   value: @state.value
        #   onChange: @onChange
        #   onBlur: @onBlur
        # })

        # (TokenInput {
        #   onChange: @onChange
        #   onInput: @onInput
        #   onSelect: @onSelect
        #   onRemove: @onRemove
        #   selected: @state.selected
        #   menuContent: @gatherComboboxOptions()
        # })
      # )
    )

# Exports
# 
cc.module('react/company/settings/tag_list').exports = MainComponent
