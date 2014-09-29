##= require stores/PersonStore

# Imports
# 
tag = React.DOM

PersonStore = cc.require('cc.stores.PersonStore')

# Main Component
# 
MainComponent = React.createClass

  # Helpers
  # 
  # gatherSomething: ->

  # Handlers
  # 
  # handleThingClick: ->

  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->

  # Component Specifications
  # 
  # getDefaultProps: ->
  getInitialState: ->
    is_published: @props.is_published

  render: ->
    (tag.div { className: 'section-block' },
      (tag.p {},
        "Your company is unpublished. It means that users won't be able find your company unless you provide them with a direct link."
      )

      (tag.p {}, "There are #{5} steps to publish your company:")

      (tag.ul {},
        (tag.li {}, 'Give your company a name') # props.name
        (tag.li {}, 'Upload logo') # @props.logotype
        (tag.li {}, 'Create first chart') # @props.charts[0].title
        (tag.li {}, 'Add some people') # _.map(PersonStore.all(), (person) -> person.attr('full_name')).join(', ')
        (tag.li {}, 'Assign keywords') # @props.tags.length
      )

      (tag.button { 
        className: 'orgpad' 
        disabled: true
      }, 
        'Publish'
      )
    )

# Exports
# 
module.exports = MainComponent
