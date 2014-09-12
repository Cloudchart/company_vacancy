@['cloud_blueprint/charts#view'] = (data) ->

  # Chart ID
  #
  ChartID = data.id

  # Main Component
  #
  ChartViewController = require('cloud_blueprint/components/chart_view_controller')
  
  # Perform data loading
  #
  
  # Render Component
  #
  React.renderComponent(ChartViewController({ key: ChartID }), document.querySelector('main'))
