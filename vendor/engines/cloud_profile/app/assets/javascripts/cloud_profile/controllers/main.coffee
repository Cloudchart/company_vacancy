##= require cloud_blueprint/react/chart_preview

# Activities
#
@['cloud_profile/main#activities'] = (data) ->
  $ -> cc.ujs.scrollable_pagination()


# Companies
#
@['cloud_profile/main#companies'] = (data) ->
  $ -> 
    cc.companies_section_chevron_toggle()
    cc.init_chart_preview()


# Settings
#
@['cloud_profile/main#settings'] = (data) ->

  # Settings / Personal
  #
  if personalComponentMountPoint = document.querySelector('[data-react-mount-point="personal"]')

    PersonalComponent = cc.require('profile/react/settings/personal')
    
    React.renderComponent PersonalComponent(data.personal), personalComponentMountPoint
