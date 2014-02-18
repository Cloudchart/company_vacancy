@cc ?= {}

#
#
#


vacancy_input_selector = "article section .identity-block.person select"


block_people = ->
  
  $document = $(document)
  
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


@cc.activate_block_people = block_people
