# @cjsx React.DOM

# Imports
# 
GlobalState = require('global_state/state')
Constants = require('constants')

PinStore = require('stores/pin_store')

Tooltip = require('components/shared/tooltip')


# Utils
#
# cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  displayName: 'InsightOrigin'

  propTypes:
    pin: React.PropTypes.object.isRequired
  
  mixins: [GlobalState.mixin, GlobalState.query.mixin]
  statics:
    queries:

      pin: ->
        """
          Pin {
            parent {
              edges {
                is_origin_domain_allowed
              }
            },
            edges {
              is_origin_domain_allowed
            }
          }
        """


  # Component Specifications
  # 
  # getDefaultProps: ->
  #   cursor:
  #     pins: PinStore.cursor.items

  # getInitialState: ->


  # Lifecycle Methods
  # 
  # componentWillMount: ->
  #   @fetch()


  # Fetchers
  #
  # fetch: ->
  #   GlobalState.fetch(@getQuery('pin'), { id: @props.pin.uuid })


  # Helpers
  #
  # getSomething: ->



  # Handlers
  # 
  # handleThingClick: (event) ->


  # Renderers
  # 
  renderOriginIcon: ->
    <i className="fa fa-code" />


  # Main render
  # 
  render: ->
    return null unless origin = @props.pin.origin

    if Constants.URL_REGEX.test(origin)
      return null unless @props.pin.is_origin_domain_allowed
      <a className="origin" href={ origin } target="_blank">
        { @renderOriginIcon() }
      </a>
    else
      <Tooltip
        className = "origin"
        element = { @renderOriginIcon() }
        tooltipContent = { origin }
      />
