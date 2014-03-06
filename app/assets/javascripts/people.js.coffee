@['people#index'] = (data) ->

    search_timeout = null

    search = ($element) ->
        value = $element.val().replace(/^\s+|\s+$/g, '') ; return if value.length < 3
        $('.search-result').html('')
        $('.ajax-loader').show()
        $.post("/companies/#{data.company_id}/people/search", query: value)

    perform_search = ($element) ->
        clearTimeout(search_timeout)
        search_timeout = setTimeout((-> search($element)), 700)

    $ ->
        $('main').on 'input propertychange', '.people-search', ->
            $('.search-result').html('')
            perform_search($(@))
