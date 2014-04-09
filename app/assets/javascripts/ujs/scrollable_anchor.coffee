jQuery ->
  # Scrollable anchor
  #
  $(document).on 'click', 'a[href^="#"][data-scrollable-anchor]', (event) ->
    $anchor = $($(@).attr('href')) ; return if $anchor.length == 0

    event.preventDefault()
    
    $(document.body).animate
      scrollTop: $anchor.offset().top
    , 250
