module.exports =

  report_content: (attributes = {}, options = {}) ->
    Promise.resolve $.ajax
      url: '/api/report_content'
      type: 'POST'
      dataType: 'json'
      data:
        report: attributes

  post_to_slack: (event_name, options = {}) ->
    Promise.resolve $.ajax
      url: '/api/track'
      type: 'POST'
      dataType: 'json'
      data:
        event_name: event_name
        options: options
