module.exports =

  report_content: (attributes = {}, options = {}) ->
    Promise.resolve $.ajax
      url: '/api/report_content'
      type: 'POST'
      dataType: 'json'
      data:
        report: attributes
