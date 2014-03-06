@['people#index'] = (data) ->
  
    pending_requests = []
    
    strip_re = /^\s+|\s+$/g
    
    url = "/companies/#{data.company_id}/people/search"

    search = ($element) ->
      value = strip_re.exec($element.val()) ; return if value.length < 3
    
      pending_requests.forEach (request) -> request.abort()
    
      pending_requests = []
      
      pending_requests.push $.post(url, query: value)
      
      data.social_networks.forEach (network) ->
        pending_requests.push $.post(url, query: value, social_network: network)
      
      $.when(pending_requests...).then ->
        pending_requests = []
        $('.ajax-loader').hide()


    $ ->
        $('.people-search').bindWithDelay 'input propertychange', ->  
            $('.search-result').html('')
            if this.value.length > 2
                $('.ajax-loader').show()
                $.when(
                    $.post("/companies/#{data.company_id}/people/search", query: this.value),
                    if data.social_networks.indexOf('facebook') > -1
                        $.post "/companies/#{data.company_id}/people/search", query: this.value, social_network: 'facebook'
                ).done (a1, a2) ->
                    $('.ajax-loader').hide()
        , 1000
