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
      dataType: 'json'
  
  
  fetchOne: (id, params = {}, options = {}) ->
    url = '/stories/' + id
    
    delete cachedPromises[url] if options.force == true

    cachedPromises[url] ||= Promise.resolve $.ajax
      url: url
      type: "GET"
      dataType: "json"
      data: params
    

  createByCompany: (company_id, attributes = {}, options = {}) ->
    Promise.resolve $.ajax
      url: "/companies/#{company_id}/stories"
      type: 'POST'
      dataType: 'json'
      data:
        story: attributes


  update: (item, attributes) ->
    Promise.resolve $.ajax
      url: "/stories/#{item.get('uuid')}"
      type: 'PATCH'
      dataType: 'json'
      data:
        story: attributes
