@cc ?= {}

@cc.companies_section_chevron_toggle = ->
  chevron_is_down = true

  $('main').on 'click', '.main-info .toggle-elements', (element) ->
    element.preventDefault()

    $(@).closest('section')
        .find('.additional-info, .country, .established-on, .proximity')
        .toggle()

    $chevron_icon = $(@).find('i')

    if chevron_is_down
      chevron_is_down = false
      $chevron_icon.attr('class', 'fa fa-chevron-up')
    else
      chevron_is_down = true
      $chevron_icon.attr('class', 'fa fa-chevron-down')

@cc.init_chart_preview = (small=false, scale=1) ->
  ChartPreviewComponent = cc.require('blueprint/react/chart-preview')
  chartPreviewContainers = document.querySelectorAll('[data-react-chart-preview-mount-point]')
    
  _.each chartPreviewContainers, (root) ->
    React.renderComponent(
      ChartPreviewComponent({
        id: root.dataset.reactChartPreviewMountPoint
        permalink: root.dataset.reactPermalink
        company_id: root.dataset.reactCompanyId
        scale: scale
        small: small
      }), root
    )
