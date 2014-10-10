@cc ?= {}

@cc.init_chart_preview = (small=false, scale=1) ->
  ChartPreviewComponent = cc.require('blueprint/react/chart-preview')
  chartPreviewContainers = document.querySelectorAll('[data-react-chart-preview-mount-point]')
    
  _.each chartPreviewContainers, (root) ->
    React.renderComponent(
      ChartPreviewComponent({
        id: root.dataset.reactChartPreviewMountPoint
        slug: root.dataset.reactSlug
        company_id: root.dataset.reactCompanyId
        scale: scale
        small: small
      }), root
    )
