##= require cloud_blueprint/react/chart_preview

# Activities
#
@['cloud_profile/main#activities'] = (data) ->
  $ -> cc.ujs.scrollable_pagination()


# Companies
#
@['cloud_profile/main#companies'] = (data) ->
  $ -> cc.companies_section_chevron_toggle()


  ChartPreviewComponent   = cc.require('blueprint/react/chart-preview')
  chartPreviewContainers  = document.querySelectorAll("[data-react-mount-point-for-chart]")
  
  _.each chartPreviewContainers, (root) ->
    chartUUID = root.dataset.reactMountPointForChart
    React.renderComponent(ChartPreviewComponent({ id: chartUUID, scale: .25 }), root)


# Settings
#
@['cloud_profile/main#settings'] = (data) ->

  # Settings / Personal
  #
  if personalComponentMountPoint = document.querySelector('[data-react-mount-point="personal"]')

    PersonalComponent = cc.require('profile/react/settings/personal')
    
    React.renderComponent PersonalComponent(data.personal), personalComponentMountPoint
