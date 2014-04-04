@['vacancies#show'] = (data) ->
  $ ->
    cc.acts_as_editable_article() if data.can_update_vacancy

    #
    # Sticky containers (TODO: use cc.ui.sticky())
    #
    sticky $('[data-behaviour~=editable-article-blocks], [data-behaviour~=editable-article-nav]'),
      offset:
        top: $('body > header').outerHeight()
