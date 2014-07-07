@['cloud_profile/main#activities'] = (data) ->
  $ ->
    cc.ujs.scrollable_pagination()

@['cloud_profile/main#companies'] = (data) ->
  $ ->
    cc.companies_section_chevron_toggle()
