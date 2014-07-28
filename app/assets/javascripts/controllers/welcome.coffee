@['welcome#index'] = (data) ->

  if data.chart_id and chartPreviewMountPoint = document.querySelector('[data-react-chart-preview-mount-point]')
    ChartPreviewComponent = cc.require('blueprint/react/chart-preview')
  
    chartPreview = ChartPreviewComponent({ id: data.chart_id, scale: 1 })

    React.renderComponent(chartPreview, chartPreviewMountPoint)