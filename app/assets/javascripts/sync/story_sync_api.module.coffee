# Cache
#
cachedPromises = {}


# Exports
#
module.exports =
  

  fetchAllByCompany: (company_id, options = {}) ->
    url = '/companies/' + company_id + '/stories'

    delete cachedPromises[url] if options.force == true
    
    cachedPromises[url] ||= Promise.resolve $.ajax
      url: url
      type: 'GET'
      dataType: 'JSON'
  
  
  fetch: (id, options = {}) ->
    url = '/stores/' + id
    
    delete cachedPromises[url] if options.force == true

    cachedPromises[url] ||= Promise.resolve $.ajax
      url: url
      type: "GET"
      dataType: "JSON"
    

  create: (company_id, attributes, done, fail) ->
    $.ajax
      url: "/companies/#{company_id}/stories"
      type: "POST"
      dataType: "json"
      data:
        story: attributes
    .done done
    .fail fail


  update: (id, attributes) ->
    Promise.resolve $.ajax
      url: "/stories/#{id}"
      type: 'PATCH'
      dataType: 'json'
      data:
        story: attributes
