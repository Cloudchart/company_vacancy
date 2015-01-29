@['stories#index'] = (data) ->

  StoriesApp = require('components/stories_app')

  # Mount stories
  # 
  React.renderComponent(
    StoriesApp({ company_id: data.company_id }), document.querySelector('body > main')
  )
