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
    _.map @state.filtered_tags || @state.available_tags, (tag) ->
      (ComboboxOption { key: tag.id, value: tag }, tag.name)

  save: ->
    selected_tags = _.map(@state.selected_tags, (tag) -> tag.name).join(', ')
    @props.onChange({ target: { selected_tags: selected_tags, available_tags: @state.available_tags } })

  availableTags: ->
    if @props.available_tags.length > 0
      @props.available_tags
    else if @props.selected_tags.length > 0
      _.filter(@props.all_tags, (tag) => !_.contains(_.pluck(@props.selected_tags, 'id'), tag.id))
    else
      @props.all_tags

  # Events
  # 
  # onChange: (event) ->

  onInput: (query) ->
    if query == '' or query == undefined
      @setState({ filtered_tags: null })
    else
      query_re = new RegExp(query, 'i')
      filtered_tags = _.filter @state.available_tags, (tag) -> query_re.test(tag.name)
      @setState({ filtered_tags: filtered_tags })

  onSelect: (value) ->
    value = { id: cc.utils.generateUUID(), name: value } unless typeof(value) == 'object'

    @setState
      selected_tags: _.union(@state.selected_tags, [value])
      available_tags: _.pull(@state.available_tags, value)
      filtered_tags: null
      should_save: true

  onRemove: (value) ->
    if value != undefined and value != ''
      @setState
        selected_tags: _.pull(@state.selected_tags, value)
        available_tags: _.union(@state.available_tags, [value]) || @props.all_tags
        filtered_tags: null
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
    selected_tags: @props.selected_tags
    available_tags: @availableTags()
    should_save: false
    filtered_tags: null

  render: ->
    # (tag.div { className: 'profile-item' },
    (tag.div {},

      (TokenInput {
        onChange: @onChange
        onInput: @onInput
        onSelect: @onSelect
        onRemove: @onRemove
        selected: @state.selected_tags
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

      # )
    )

# Exports
# 
cc.module('react/company/settings/tag_list').exports = MainComponent
