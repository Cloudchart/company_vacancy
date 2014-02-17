@['companies#show'] = ->
    $ ->
      
        $document = $(document)
        $body     = $(document.body)
      
        sticky $('[data-behaviour~=editable-article-blocks], [data-behaviour~=editable-article-nav]'),
            offset:
                top: $('body > header').outerHeight()
        

        
        cc.touchdrag 'aside.blocks [data-behaviour~=draggable]',
          start: ->

          stop: ->

          drag: ->
          
        #$('aside.blocks [data-behaviour~=draggable]').draggable({ helper: 'clone' })
        
        
        $(document).on 'click', 'a[href^="#"][data-scrollable-anchor]', (event) ->
          $anchor = $($(@).attr('href')) ; return if $anchor.length == 0

          event.preventDefault()
          
          $(document.body).animate
            scrollTop: $anchor.offset().top
          , 250

        
        $(document).on 'submit', 'form.block_identity', (event) ->

        cc.activate_block_vacancies()
