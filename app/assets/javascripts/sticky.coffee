$ = jQuery


$document   = null
$window     = null


defaults    = 
    offset: 0


sticky = (el, options = {}) ->
    $el = $(el) ; return if $el.length == 0
    
    
    glued       = false
    unpin       = null
    
    
    options     = $.extend {}, defaults, options
    
    
    check_position = ->
        return unless $el.is(':visible')
        
        scroll_height   = $document.height()
        scroll_top      = $window.scrollTop()
        position        = $el.offset()
        offset          = options.offset
        offset_top      = offset.top
        offset_bottom   = offset.bottom
        
        
        offset_top = offset_bottom = offset unless typeof offset == 'object'
        
        offset_top      = offset_top()      if typeof offset_top    == 'function'
        offset_bottom   = offset_bottom()   if typeof offset_bottom == 'function'
        
        
        should_be_glued = if unpin? and ((scroll_top + unpin) <= position.top)
            false
        else if offset_bottom? and ((position.top + $el.height()) >= (scroll_height - offset_bottom))
            'bottom'
        else if offset_top? and (scroll_top <= offset_top)
            'top'
        else
            false
        
        return if glued == should_be_glued
        
        $el.css('top', 'auto') if unpin?
        
        glued = should_be_glued
        unpin = if glued == 'bottom' then position.top - scroll_top else null
        
        $el.removeClass('glued glued-top glued-bottom').addClass('glued' + if glued then '-' + glued else '')
        
        if glued == 'bottom'
            $el.offset
                top: document.body.offsetHeight - offset_bottom - $el.height()
    
    
    $window.on "scroll", check_position
    
    check_position()
    

@sticky = sticky    


$ ->
    $document   = $(document)
    $window     = $(window)
