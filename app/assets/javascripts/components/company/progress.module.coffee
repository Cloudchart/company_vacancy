# Imports
# 
tag = React.DOM

# PersonStore = cc.require('cc.stores.PersonStore')

# Main Component
# 
MainComponent = React.createClass

  # Helpers
  # 
  progressItems: ->
    [
      { message: 'Give your company a name', is_checked: !!@props.name },
      { message: 'Upload logo', is_checked: !!@props.logotype },
      { message: 'Create first chart', is_checked: !!@props.is_chart_with_nodes_created },
      { message: 'Add some people', is_checked: @props.people.length > 0 },
      { message: 'Assign keywords', is_checked: @props.tag_list.length > 0 }
    ]

  progressItem: (item, index) ->
    classes = React.addons.classSet({ checked: item.is_checked })

    (tag.li { key: index },
      (tag.span { className: classes }, item.message)
      (tag.i { className: 'fa fa-check' }) if item.is_checked
    )

  progressItemsLeft: ->
    _.reduce @progressItems(), (sum, item) ->
      sum + !item.is_checked | 0
    , 0

  progressStatusMessage: ->
    items_left = @progressItemsLeft()

    if items_left == 0 and !@props.is_published
      'Looks good. You may now publish your company.'
    else if items_left == 1
      'There is one more step to publish your company:'
    else
      "There are #{items_left} steps to publish your company:"

  progressStateMessage: ->
    if @props.is_published
      'Your company is published.'
    else
      "Your company is unpublished. It means that users won't be able find your company unless you provide them with a direct link."

  classForButtonIcon: ->
    if @state.sync
      'fa fa-spinner fa-spin' 
    else if @props.is_published
      'fa fa-undo'
    else 
      'fa fa-globe'

  # Handlers
  # 
  handlePublishClick: (event) ->
    @setState({ sync: true })
    @props.onChange({ target: { value: if @props.is_published then false else true } })

  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  componentWillReceiveProps: (nextProps) ->
    @setState({ sync: false })
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->

  # Component Specifications
  # 
  # getDefaultProps: ->
  getInitialState: ->
    sync: false

  render: ->
    (tag.div { className: 'section-block' },
      (tag.p {}, @progressStateMessage())

      (tag.p {}, @progressStatusMessage()) unless @props.is_published

      (tag.ul {},
        _.map _.sortBy(@progressItems(), 'is_checked'), (item, index) => @progressItem(item, index)
      ) unless @props.is_published

      (tag.button { 
        className: 'orgpad'
        onClick: @handlePublishClick
        disabled: @progressItemsLeft() > 0 or @state.sync
      },
        (tag.span {}, if @props.is_published then 'Unpublish' else 'Publish')
        (tag.i { className: @classForButtonIcon() })
      )
    )

# Exports
# 
module.exports = MainComponent
