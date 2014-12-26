module.exports =
  
  
  fetch:  (id, done, fail) ->
    $.ajax
      url:      "/stories/#{id}"
      type:     "GET"
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
