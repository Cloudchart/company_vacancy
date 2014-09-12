@['cloud_blueprint/charts#view'] = (data) ->

  # Chart ID
  #
  ChartID = data.id

  # Main Component
  #
  ChartViewController = require('cloud_blueprint/components/chart_view_controller')
  
  # Perform data loading
  #
  ChartStore    = require('cloud_blueprint/stores/chart_store')
  ChartSyncAPI  = require('cloud_blueprint/utils/chart_sync_api')
  
  chartXHR = ChartSyncAPI.fetch(ChartID)
  
  # Render Component
  #
  Promise.all([chartXHR]).then ->
    React.renderComponent(ChartViewController({ key: ChartID }), document.querySelector('main'))
