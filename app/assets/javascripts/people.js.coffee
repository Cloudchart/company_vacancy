@['people#index'] = (data) ->

    search_timeout = null
    url = "/companies/#{data.company_id}/people/search"

    search = ($element) ->
        value = $element.val().replace(/^\s+|\s+$/g, '') ; return if value.length < 3
        requests = []
        $('.ajax-loader').show()

        # regular request
        requests.push $.post(url, query: value)

        # social networks requests
        data.social_networks.forEach (network) ->
            requests.push $.post(url, query: value, social_network: network)

        $.when(requests...).then ->
            $('.ajax-loader').hide()

    perform_search = ($element) ->
        clearTimeout(search_timeout)
        search_timeout = setTimeout((-> search($element)), 1000)

    $ ->
        $('main').on 'input propertychange', '.people-search', ->
            $('.search-result').html('')
            perform_search($(@))
