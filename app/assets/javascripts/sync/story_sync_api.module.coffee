module.exports =

  create: (company_id, attributes, done, fail) ->
    $.ajax
      url: "/companies/#{company_id}/stories"
      type: "POST"
      dataType: "json"
      data:
        story: attributes
    .done done
    .fail fail
