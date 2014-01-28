@['companies#show'] = ->
    $ ->
        sticky $('article aside.blocks'),
            offset:
                top: $('body > header').outerHeight()

        
        cc.touchdrag('article aside.blocks', {
            selector: '[data-behaviour~=draggable]',
            dragstart: (e, el) ->
                $(el).addClass('drag')
            dragend: (e, el) ->
                $(el).removeClass('drag')
        })
        
        $('[data-behaviour~=draggable]').on 'mouseup', ->
            alert(1)