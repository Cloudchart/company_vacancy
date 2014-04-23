$ ->
  $('a[data-back]').on 'click', (event) -> event.preventDefault() ; history.back()
