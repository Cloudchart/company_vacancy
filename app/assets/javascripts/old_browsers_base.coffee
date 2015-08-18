$('.button a').on 'click', ->
  Cookies.set('agree_to_browse', true, { expires: 1 });
