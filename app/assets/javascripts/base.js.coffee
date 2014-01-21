jQuery ->
    # toggable section
    $('main').on 'click', '.toggleable-link', (event) -> 
        $i = $(this).find('i')

        $(this).parent().next('.toggleable-content').toggle 0, ->
            if $i.hasClass('fa-caret-down')
                $i.removeClass().addClass('fa fa-caret-right')
            else
                $i.removeClass().addClass('fa fa-caret-down')

        event.preventDefault()
