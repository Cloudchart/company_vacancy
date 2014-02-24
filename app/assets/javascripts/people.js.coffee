@['people#index'] = (data) ->
    $ ->
      $('.people-search').bindWithDelay 'input propertychange', ->  
        $('.search-result').html('')
        if this.value.length > 2
          $('.ajax-loader').show()
          $.post "/companies/#{data.company_id}/people/search", query: this.value
      , 1000
