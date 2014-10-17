###
  Used in:

  cloud_profile/main#activities
###

@cc ?= {}
@cc.ujs ?= {}

$ = jQuery

#
#
#

widget = ->

  $(window).scroll ->
    url = $('.pagination .next a').attr('href')
    if url && $(window).scrollTop() > $(document).height() - $(window).height() - $('footer').outerHeight()
      $('.pagination').text('Fetching more records...')
      $.getScript(url)
  $(window).scroll()  

#
#
#

$.extend @cc.ujs,
  scrollable_pagination: widget
