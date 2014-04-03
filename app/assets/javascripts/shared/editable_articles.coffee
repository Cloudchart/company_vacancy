@cc ?= {}

@cc.acts_as_editable_article = ->
  # Company side nav remote update
  #
  $side_nav_remote_form = $('nav[data-behaviour~=editable-article-nav] .edit_company')
  
  $side_nav_remote_form.on 'change', '#company_logo_attributes_image', (event) ->
    $(this).closest('form').submit()

  $side_nav_remote_form.on 'blur', '#company_description', (event) ->
    $(this).closest('form').submit() 

  # Drag and drop
  #
  cc.ui.drag_drop($(document), 'li[data-behaviour~="draggable"]', {
    drop_on: 'article'
  })
  
  cc.ui.droppable()

  # Article paragraph
  #    
  cc.plugins.article_paragraph()

  # Identity Block - Person
  #
  cc.activate_block_people()

  # Identity Block - Vacancy
  #
  cc.activate_block_vacancies()

  # Identity Block - Company
  #
  cc.activate_block_companies()

  
  current_placeholder = null
  
  
  create_placeholder = ->
    el = document.createElement('div')
    el.className = 'droppable-placeholder'
    el
  
  
  insert_placeholders = (element) ->
    sections = element.querySelectorAll('section')
    
    Array.prototype.forEach.call sections, (section) ->
      section.appendChild(create_placeholder())
      
      blocks = section.querySelectorAll('.identity-block')
      
      Array.prototype.forEach.call blocks, (block) ->
        block.parentNode.insertBefore(create_placeholder(), block)
      
  
  remove_placeholders = (element) ->
    placeholders = element.querySelectorAll('.droppable-placeholder')
    Array.prototype.forEach.call placeholders, (placeholder) ->
      placeholder.parentNode.removeChild(placeholder)
  

  find_closest_placeholder = (element, event) ->
    y = event.pageY - window.pageYOffset
    
    placeholders = element.querySelectorAll('.droppable-placeholder')
    
    data = Array.prototype.reduce.call placeholders, (memo, placeholder) ->
      bounds = placeholder.getBoundingClientRect()
      if memo == null or Math.abs(bounds.top - y) < Math.abs(memo.bounds.bottom - y)
        memo =
          bounds:   bounds
          element:  placeholder
      memo
    , null
    
    data.element
  

  $('main').on "cc::drag:drop:enter", 'article', (event) ->
    event.stopPropagation()
    current_placeholder = null
    insert_placeholders(@)
    console.log 'enter'


  $('main').on "cc::drag:drop:leave", 'article', (event) ->
    event.stopPropagation()
    current_placeholder = null
    remove_placeholders(@)
    console.log 'leave'


  $('main').on "cc::drag:drop:move", 'article', (event) ->
    event.stopPropagation()

    
    current_placeholder.style.opacity = .25 unless current_placeholder == null
    current_placeholder = find_closest_placeholder(@, event)
    current_placeholder.style.opacity = .75


  $('main').on "cc::drag:drop:drop", 'article', (event) ->
    event.stopPropagation()
    
    
    sibling = current_placeholder.previousSibling
    sibling = sibling.previousSibling while sibling and sibling.nodeType == 3
    index   = Array.prototype.indexOf.call($(current_placeholder).closest('section')[0].querySelectorAll('.identity-block'), sibling) + 1
    
    form    = $('#new-article-block-form')
    
    $('[name="block\[section\]"]').val($(current_placeholder).closest('section').data('name'))
    $('[name="block\[identity_type\]"]').val($(event.draggableTarget).data('type'))
    $('[name="block\[position\]"]').val(index)
    
    
    request = $.ajax
      url:  form.attr('action')
      type: form.attr('method')
      data: form.serializeArray()
      dataType: 'script'          

    console.log 'drop'