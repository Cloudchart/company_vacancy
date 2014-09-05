# Imports
# 
tag = React.DOM
current_date = new Date
current_month = current_date.getMonth()

# SomeComponent = cc.require('')

# Main Component
# 
MainComponent = React.createClass

  # Component Specifications
  # 
  render: ->
    (tag.article { className: 'editor burn-rate' },
      (tag.table {},
        (tag.thead {},
          (tag.tr {},
            (tag.th {}, moment(current_date.setMonth(current_month - 4)).format('MMM YY'))
            (tag.th {}, moment(current_date.setMonth(current_month - 3)).format('MMM YY'))
            (tag.th {}, moment(current_date.setMonth(current_month - 2)).format('MMM YY'))
            (tag.th {}, moment(current_date.setMonth(current_month - 1)).format('MMM YY'))
            (tag.th {}, moment().format('MMM YY'))
          )
        )
        (tag.tbody {},
          (tag.tr {},
            (tag.td {})
            (tag.td {})
            (tag.td {})
            (tag.td {})
            (tag.td {})
          )
        )
      )
    )

  # getInitialState: ->
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
  # gatherSomething: ->

  # Events
  # 
  # onThingClick: ->

# Exports
# 
cc.module('react/company/burn_rate').exports = MainComponent
