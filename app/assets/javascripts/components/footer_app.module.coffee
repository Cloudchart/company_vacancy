# @cjsx React.DOM

# Imports
# 
GlobalState = require('global_state/state')
UserStore = require('stores/user_store.cursor')
ModalStack = require('components/modal_stack')
ReportContent = require('components/shared/report_content')

# Utils
#
# cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  displayName: 'FooterApp'

  propTypes:
    links: React.PropTypes.array.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      viewer: ->
        """
          Viewer {
            edges {
              is_authenticated
            }
          }
        """


  # Component Specifications
  # 
  getDefaultProps: ->
    cursor:
      viewer: UserStore.me()

  fetch: ->
    GlobalState.fetch(@getQuery('viewer'))

  # getInitialState: ->

  
  # Lifecycle Methods
  # 
  componentWillMount: ->
    @fetch()

  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


  # Helpers
  # 
  # getSomething: ->


  # Handlers
  # 
  handleLinkClick: (link, event) ->
    event.preventDefault() unless link.href

    switch link.id
      when 'report-content'
        if @props.cursor.viewer.get('is_authenticated')
          ModalStack.show(<ReportContent/>)
        else
          location.href = '/auth/twitter'
          return null


  # Renderers
  # 
  renderLinks: ->
    @props.links.map (link, index) =>
      <li key={ index }>
        <a href={ link.href } onClick={ @handleLinkClick.bind(@, link) }>{ link.name }</a>
      </li>


  # Main render
  # 
  render: ->
    <ul>
      { @renderLinks() }
    </ul>
