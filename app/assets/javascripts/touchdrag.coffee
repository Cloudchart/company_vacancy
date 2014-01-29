@cc ?= {}

$ = jQuery

$document   = null
$window     = null
$body       = null


in_transition   = false

tolerance       = 50

events =
    start:  'mousedown touchstart'
    move:   'mousemove touchmove'
    end:    'mouseup touchend touchcancel'


defaults = {}


#
#
#


touchdrag = (element_or_selector, options = {}) ->
    
    $element    = null
    selector    = null
    
    if typeof element_or_selector == 'string'
        $element    = $document
        selector    = element_or_selector
    else
        $element    = $(element_or_selector)
    
    return if $element.length == 0

    options = $.extend {}, defaults, options
    

    callbacks =
        dragstart:  new $.Callbacks
        dragmove:   new $.Callbacks
        dragend:    new $.Callbacks
    
    
    Object.keys(callbacks).forEach (name) ->
        callbacks[name].add(options[name]) if options[name]? and typeof(options[name]) == 'function'


    #
    # Capture drag event
    #
    
    capture = (event, el) ->


        check_timeout = setTimeout((-> start(event, el) ; check_end()), 500)


        check_move = (check_event) ->
            dx = Math.abs(event.originalEvent.pageX - check_event.originalEvent.pageX)
            dy = Math.abs(event.originalEvent.pageY - check_event.originalEvent.pageY)
            
            if (Math.sqrt(dx * dx + dy * dy) > 5)
                start(event, el)
                check_end()
            

        check_end = ->
            $document.off events.move,  check_move
            $document.off events.end,   check_end
            clearTimeout(check_timeout)

        
        $document.on events.move,   check_move
        $document.on events.end,    check_end
    

    #
    # Start drag
    #
    
    start = (original_event, element) ->
        
        $el = $(element)
        
        in_transition   = true
        animation       = false
        
        origin =
            x: original_event.originalEvent.pageX
            y: original_event.originalEvent.pageY
        

        update = (event) ->
            event.cc_draggable =
                x:      event.originalEvent.pageX
                y:      event.originalEvent.pageY
                dx:     event.originalEvent.pageX - origin.x
                dy:     event.originalEvent.pageY - origin.y
                ox:     origin.x
                oy:     origin.y
            event
        
        
        scroll = (event) ->
            document_height = $document.height()
            viewport_height = $window.height()
            viewport_scroll = $window.scrollTop()
            
            y = event.originalEvent.pageY - viewport_scroll
            
            if y < (0 + tolerance)
                return if animation or viewport_scroll == 0
                $body.animate
                    scrollTop: 0
                ,
                    duration: viewport_scroll / 2
                    easing: 'linear'
                animation = true
            
            else if y > (viewport_height - tolerance)
                return if animation or viewport_scroll == document_height
                $body.animate
                    scrollTop: document_height
                ,
                    duration: document_height / 2 - viewport_scroll / 2
                    easing: 'linear'
                animation = true
            
            else
                return unless animation
                $body.stop()
                animation = false
            
        
        
        dragmove = (event) ->
            return if event.originalEvent.touches and event.originalEvent.touches.length > 1
            scroll(event)
            callbacks.dragmove.fire(update(event), element)
        

        dragend = (event) ->
            $document.off   events.move,    dragmove
            $document.off   events.end,     dragend
            callbacks.dragend.fire(update(event), element)
            in_transition = false


        callbacks.dragstart.fire(update(original_event), element)


        $document.on    events.move,   dragmove
        $document.on    events.end,    dragend
    

    # mousedown and touchstart
    #

    $element.on events.start, selector, (event) ->
        return if in_transition
        return if event.originalEvent.touches and event.originalEvent.touches.length > 1
        
        event.preventDefault()
        
        capture(event, @)


    # Public interface
    #

    null

#
#
#


$ ->
    $window     = $(window)
    $document   = $(document)
    $body       = $('body', $document)


@cc.touchdrag = touchdrag
