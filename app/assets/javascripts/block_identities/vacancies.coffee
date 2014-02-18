@cc ?= {}

#
#
#


vacancy_input_selector = "article section .identity-block.vacancy select"
delete_vacancy_input_selector = "article section .identity-block.vacancy [data-behaviour~='delete-vacancy']"


block_vacancies = ->
  
  $document = $(document)
  
  set_new_vacancy_value = ($element) ->
  
  $document.on 'change', vacancy_input_selector, ->
    $el = $(@)
    
    if $el.val()
      $el.closest('form').find("select").not($el).each ->
        $select = $(@)

        if $select.val() == $el.val()
          $select.val($el.data('value'))
          $select.data('value', $select.val())
    
    $el.data('value', $el.val())
    
    $el.closest('form').submit()
    
    
#
#
#


@cc.activate_block_vacancies = block_vacancies
