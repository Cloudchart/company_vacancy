@['companies#show'] = ->
    $ ->
      
        $document = $(document)
        $body     = $(document.body)
      

        sticky $('[data-behaviour~=editable-article-blocks], [data-behaviour~=editable-article-nav]'),
            offset:
                top: $('body > header').outerHeight()
        

        
        $(document).on 'click', 'a[href^="#"][data-scrollable-anchor]', (event) ->
          $anchor = $($(@).attr('href')) ; return if $anchor.length == 0

          event.preventDefault()
          
          $(document.body).animate
            scrollTop: $anchor.offset().top
          , 250


        #
        # Identity Block - Person
        #
        
        cc.activate_block_people()

        #
        # Identity Block - Vacancy
        #
        
        cc.activate_block_vacancies()
