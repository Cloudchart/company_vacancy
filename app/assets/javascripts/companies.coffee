@['companies#show'] = (data) ->
  $ ->
    cc.acts_as_editable_article() if data.can_update_company
    cc.acts_as_editable_side_nav() if data.can_update_company

    # Sticky containers (TODO: use cc.ui.sticky())
    #
    sticky $('[data-behaviour~=editable-article-blocks], [data-behaviour~=editable-article-nav]'),
      offset:
        top: $('body > header').outerHeight()

@['companies#index'] = (data) ->
  $ ->
    $('main').on 'click', '.companies-search .search-result .main-info .toggle-elements', ->
      $(@).closest('section')
          .find('.additional-info, .country, .established-on, .charts, .vacancies, .proximity')
          .toggle('slow')

      $toggle_icon = $(@).closest('section').find('.toggle-elements i')
      if $toggle_icon.hasClass('fa fa-chevron-down')
        $toggle_icon.removeClass().addClass('fa fa-chevron-up')
      else
        $toggle_icon.removeClass().addClass('fa fa-chevron-down')


      # .companies-search .search-result .content .charts,
      # .companies-search .search-result .content .vacancies'

  #   $('.company').on 'input propertychange', '#query', ->
  #     perform_search($(@))


  #   $('.company').on 'change', '#country, #industry_id', ->
  #     $(@).closest('form').submit()

  #   $(document).ajaxStart ->
  #     $('.company .result').hide()

  # search_timeout = null

  # search = ($element) ->
  #   value = $element.val().replace(/^\s+|\s+$/g, '') 
  #   return if value.length < 3 and value.length > 0

  #   $element.closest('form').submit()

  # perform_search = ($element) ->
  #   clearTimeout(search_timeout)
  #   search_timeout = setTimeout((-> search($element)), 700)
