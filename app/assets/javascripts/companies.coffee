@['companies#show'] = ->
    $ ->
      
        $document = $(document)
        $body     = $(document.body)
      

        sticky $('[data-behaviour~=editable-article-blocks], [data-behaviour~=editable-article-nav]'),
            offset:
                top: $('body > header').outerHeight()
        
        $(document).on 'click', 'a[href^="#"][data-scrollable-anchor]', (event) ->
          $anchor = $($(@).attr('href')) ; return if $anchor.length == 0

          event.preventDefault()
          
          $(document.body).animate
            scrollTop: $anchor.offset().top
          , 250


        #
        # Identity Block - Person
        #
        
        cc.activate_block_people()

        #
        # Identity Block - Vacancy
        #
        
        cc.activate_block_vacancies()

        #
        #
        #
        
        cc.ui.drag_drop($document, 'li[data-behaviour~="draggable"]', {
          drop_on: 'article'
        })
        
        
        #
        # Article paragraph
        #
        
        cc.plugins.article_paragraph()
        
        
        #
        # Droppable
        #
        

        cc.ui.droppable()
        
        
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
          
          
          form.submit()
          
          
          console.log 'drop'
          
