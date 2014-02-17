@cc ?= {}

#
#
#


new_vacancy_input_selector = "article section .identity-block.vacancy select.new"
delete_vacancy_input_selector = "article section .identity-block.vacancy [data-behaviour~='delete-vacancy']"


block_vacancies = ->
  
  $document = $(document)
  
  $document.on 'change', new_vacancy_input_selector, ->
    $(@).closest('form').submit()
    
  
  $document.on 'click', delete_vacancy_input_selector, ->
    $el     = $(@)
    uuid    = $el.data('vacancy-id')
    $form   = $el.closest('form')

    $form.find("input[value=#{uuid}]").val(null)
    $form.submit()


#
#
#


@cc.activate_block_vacancies = block_vacancies
