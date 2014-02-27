@['people#index'] = (data) ->
    $ ->
        $('main').on 'input propertychange', '.people-search', ->
            $('.search-result').html('')
            if this.value.length > 2
                $('.ajax-loader').show()
                $.when(
                    $.post("/companies/#{data.company_id}/people/search", query: this.value),
                    if data.social_networks.indexOf('facebook') > -1
                        $.post "/companies/#{data.company_id}/people/search", query: this.value, social_network: 'facebook'
                ).done (a1, a2) ->
                    $('.ajax-loader').hide()
