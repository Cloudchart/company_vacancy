@cc ?= {}

# Company side nav remote update
#
@cc.acts_as_editable_side_nav = ->
  $('nav[data-behaviour~="editable-article-nav"]').on 'change', '#company_logo_attributes_image', (event) ->
    formData = new FormData()
    formData.append $(@).attr('name'), $(@)[0].files[0]

    $.ajax
      url: $('form.edit_company').attr('action')
      data: formData
      dataType: 'script'
      type: 'PUT'
      cache: false
      contentType: false
      processData: false

  $('nav[data-behaviour~="editable-article-nav"]').on 'blur', '#company_description', (event) ->
    $(this).closest('form').submit()
