@['companies#show'] = ->
    $ ->
        sticky $('article aside.blocks, nav'),
            offset:
                top: $('body > header').outerHeight()
        
        draggable_block = null
        origin =
            left:   0
            top:    0
        
        cc.touchdrag('article aside.blocks [data-behaviour~=draggable]', {

            dragstart: (e, el) ->
                $el = $(el)

                $el.addClass('active')

                draggable_block = $el.clone().appendTo($(el).parent())

                draggable_block.addClass('drag')

                draggable_block.css
                    width: $el.outerWidth()
                    height: $el.outerHeight()
                    left:   $el.position().left
                    top:    $el.position().top
                    zIndex: 1000
                
                draggable_block.css
                    position: 'absolute'

            
            dragmove: (e, el) ->
                $el = $(el)
                
                draggable_block.css
                    left: $el.position().left + e.cc_draggable.dx
                    top: $el.position().top + e.cc_draggable.dy
                

            dragend: (e, el) ->
                $el = $(el)
                $el.removeClass('active')
                draggable_block.remove()

        })
