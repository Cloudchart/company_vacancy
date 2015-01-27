module.exports =
  

  fetchAll: (company_id) ->
    Promise.resolve $.ajax
      url: "/companies/#{company_id}/stories"
      type: 'GET'
      dataType: 'JSON'

  
  fetch: (id, done, fail) ->
    $.ajax
      url: "/stories/#{id}"
      type: "GET"
      dataType: "JSON"
    .done done
    .fail fail
    

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
