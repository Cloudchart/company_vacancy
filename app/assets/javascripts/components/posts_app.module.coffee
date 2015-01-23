# @cjsx React.DOM


# Imports
# 
tag = React.DOM
cx = React.addons.classSet

GlobalState = require('global_state/state')

PostStore = require('stores/post_store')
CompanyStore = require('stores/company')
StoryStore = require('stores/story_store')

Timeline = require('components/company/timeline')
ContentEditableArea = require('components/form/contenteditable_area')


# Main
# 
MainComponent = React.createClass

  mixins: [GlobalState.mixin]
  # propTypes: {}
  displayName: 'Posts app'


  # Helpers
  # 
  # gatherSomething: ->


  # Handlers
  # 
  handleStoryDescriptionChange: (value) ->
    StoryStore.update(@props.story_id, { description: value })


  # Lifecycle Methods
  # 
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)

  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)


  # Component Specifications
  # 
  getDefaultProps: ->
    cursor:
      company_flags: GlobalState.cursor(['stores', 'companies', 'flags'])
      stories: StoryStore.cursor.items

  refreshStateFromStores: ->
    @setState @getStateFromProps(@props)

  getStateFromProps: (props) ->
    company: CompanyStore.get(props.company_id)

  onGlobalStateChange: ->
    @setState
      refreshed_at: + new Date
      readOnly: @props.cursor.company_flags.cursor([@props.company_id]).get('is_read_only')

  getInitialState: ->
    _.extend @getStateFromProps(@props),
      readOnly: true

  render: ->
    story = @props.cursor.stories.cursor(@props.story_id)
    return null unless story.deref(Immutable.Map()).size > 0

    <div className="wrapper">
      <header>
        <h1>{story.get('name')}</h1>

        <label className="description">
          <ContentEditableArea
            onChange = { @handleStoryDescriptionChange }
            placeholder = 'Tap to add description'
            readOnly = { @state.readOnly }
            value = { story.get('description') }
          />
        </label>
      </header>

      <Timeline 
        company_id = { @props.company_id }
        story_id = { @props.story_id }
        readOnly = { @state.readOnly }
      />
    </div>


# Exports
# 
module.exports = MainComponent
