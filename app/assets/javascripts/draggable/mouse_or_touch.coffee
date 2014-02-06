@cc    ?= {}

$       = jQuery


events =
    down:   'mousedown touchstart'
    move:   'mousemove touchmove'
    up:     'mouseup touchend touchcancel'
    click:  'click'

Object.keys(events).forEach (name) -> events[name] = events[name].split(' ').map((event) -> "#{event}.mouse_or_touch").join(' ')


mouse_or_touch_prevent_click_event = 'mouse_or_touch.prevent_click_event'


defaults =
    distance:   5
    delay:      250


mouse_or_touch_captured = false


#
#
#


plugin = (selector_or_element, options = {}) ->
    
    options         = $.extend {}, defaults, options

    $document       = $(document)
    $element        = null
    selector        = null
    
    captured_event      = null
    drag_in_transition  = false
    delay_valid         = false
    

    if selector_or_element instanceof $ or selector_or_element instanceof Node
        $element = $(selector_or_element)
        selector = null
    else
        $element = $document
        selector = selector_or_element


    callbacks = 'down move up start drag stop'.split(' ').reduce (memo, name) ->
        memo[name] = if options[name] and $.isFunction(options[name]) then options[name] else $.noop
        memo
    , {}
        
    
    #
    # Capture mouse or touch down events
    #
    
    capture = ->
        $element.on events.down, selector, mouse_or_touch_down
        
        $element.on events.click, selector, prevent_mouse_click
        
        mouse_or_touch_captured = false
    

    #
    # Mouse or touch down callback
    #
    
    mouse_or_touch_down = (event) ->
        return if mouse_or_touch_captured

        captured_event = event
        
        delay_valid = !options.delay ; setTimeout(delayed_activation, options.delay) unless delay_valid
        
        if distance_valid(event) or delay_valid
            drag_in_transition = true
            callbacks['start'](captured_event)
        
        if ($.data(event.target, mouse_or_touch_prevent_click_event)) == true
            $.removeData(event.target, mouse_or_touch_prevent_click_event)
        
        $document.on events.move, mouse_or_touch_move
        $document.on events.up, mouse_or_touch_up
        
        event.preventDefault()
        
        mouse_or_touch_captured = true
    

    #
    # Mouse or touch move callback
    #
    
    mouse_or_touch_move = (event) ->
        
        if drag_in_transition
            callbacks['drag'](event)
            return event.preventDefault()
        
        if distance_valid(event) or delay_valid
            drag_in_transition = true
            callbacks['start'](captured_event)
            callbacks['drag'](event)
        
        return !drag_in_transition
    
    
    #
    # Mouse or touch up callback
    #
    
    mouse_or_touch_up = (event) ->
        $document.off events.move, mouse_or_touch_move
        $document.off events.up, mouse_or_touch_up
        
        if drag_in_transition
            drag_in_transition = false
            if event.target == captured_event.target
                $.data(event.target, mouse_or_touch_prevent_click_event, true)
            
            callbacks['stop'](event)
        
        mouse_or_touch_captured = false
        
        false
    

    #
    # Prevent mouse click after drag
    #
    
    prevent_mouse_click = (event) ->
        if $.data(event.target, mouse_or_touch_prevent_click_event) == true
            $.removeData(event.target, mouse_or_touch_prevent_click_event)
            event.stopImmediatePropagation()
            return false
    

    #
    # Valid distance
    #
    
    distance_valid = (event) ->
        dx = event.pageX - captured_event.pageX
        dy = event.pageY - captured_event.pageY
        Math.sqrt(dx * dx + dy * dy) >= options.distance
    

    #
    # Delayed activation
    #
    
    delayed_activation = ->
        unless drag_in_transition
            delay_valid         = true
            drag_in_transition  = true
            callbacks['start'](captured_event)
    
    
    #
    # Initialize
    #
    
    capture()
    
    #
    # Public interface
    #
    
    null
    
#
#
#

@cc.mouse_or_touch = plugin
