$('.button a').on 'click', ->
  $.cookie('agree_to_browse', true, { expires: 1 });