jQuery ->
    # toggable section
    $('main').on 'click', '.toggleable-link', (event) -> 
        $link = $(this)

        $link.parent().next('.toggleable-content').toggle 0, ->
            if $link.prev('i').hasClass('fa-caret-down')
                $link.prev('i').removeClass().addClass('fa fa-caret-right')
            else
                $link.prev('i').removeClass().addClass('fa fa-caret-down')

        event.preventDefault()
