###
  Used in:

  shared/editable_articles
###

@cc ?= {}

#
#
#

company_input_selector = "article section .identity-block.company select"
delete_company_input_selector = "article section .identity-block.company [data-behaviour~='delete-company']"


block_companies = ->
  
  $document = $(document)
  
  $document.on 'change', company_input_selector, ->
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


@cc.activate_block_companies = block_companies
