@cc ?= {}

# Company side nav remote update
#
@cc.acts_as_editable_side_nav = ->
  $('nav[data-behaviour~="editable-article-nav"]').on 'change', '#company_logo_attributes_image', (event) ->
    cc.utils.form_data_ajax_call($(@))

  $('nav[data-behaviour~="editable-article-nav"]').on 'blur', '#company_description', (event) ->
    $(@).closest('form').submit()
