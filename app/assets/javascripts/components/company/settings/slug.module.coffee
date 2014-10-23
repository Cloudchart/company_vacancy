tag = React.DOM

# # RemoveSlugComponent
# # 
# RemoveSlugComponent = React.createClass

#   render: ->
#     (tag.button { 
#       className: 'orgpad alert' 
#       onClick: @save
#       disabled: true if @state.sync
#     },
#       (tag.span {}, 'Remove')
#       (tag.i { 
#         className: if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-eraser' 
#       })
#     )

#   getInitialState: ->
#     sync: false
#     error: false

#   save: ->    
#     data = new FormData
#     data.append('company[slug]', '')

#     @setState({ sync: true })

#     $.ajax
#       url: @props.company_url
#       data: data
#       type: 'PUT'
#       dataType: 'json'
#       contentType:  false
#       processData:  false

#     .done @onSaveDone
#     .fail @onSaveFail

#   onSaveDone: (json) ->
#     url = window.location.href
#     parts = url.split('/')
#     parts.pop()
#     parts.pop()
#     parts.push(@props.company_uuid)
#     parts.push('settings')
#     window.location.href = parts.join('/')
#     #history.replaceState(null, document.title, parts.join('/'))

#     @setState({ sync: false })
#     @props.onChange()

#   onSaveFail: ->
#     console.warn 'RemoveSlugComponent fail'

# Main Component
# 
Slug = React.createClass

  render: ->
    # if @state.is_slug_valid
    #   <div className='profile-item'>
    #     <div className='content field'>
    #       <span className='label'>Short URL</span>
    #       <span>'cloudchart.co/companies/'</span>
    #       <span>@state.value</span>
    #     </div>

    #     <div className='actions'>
    #       <RemoveSlugComponent
    #         company_uuid=@props.company_uuid
    #         company_url=@props.company_url
    #         onChange=@onRemoveSlugChange
    #       />
    #     </div>
    #   </div>
    # else
    #   <div className='profile-item'>
    #     <div className='content field'>
    #       <label htmlFor='slug'>Short URL</label>
    #       <div className='spacer'></div>
    #       <span>@props.default_host + '/companies/'</span>

    #       <input
    #         id='slug'
    #         name='slug'
    #         value=@state.value
    #         placeholder='shortname'
    #         className='error' if @state.error
    #         onKeyUp=@onKeyUp
    #         onChange=@onChange
    #       />
    #     </div>

    #     <div className='actions'>
    #       <button
    #         className='orgpad'
    #         onClick=@onClick
    #         disabled={true if @state.sync or @state.value == '' or @state.value == null}
    #       >
    #         <span>Save</span> 
    #         <i className={if @state.sync then 'fa fa-spinner fa-spin' else 'fa fa-save'}></i>
    #       </button>
    #       </div>
    #     </div>
    #   </div>

  getInitialState: ->
    value: @props.value
    sync: false
    error: false
    is_slug_valid: 
      if @props.value == '' or @props.value == null 
        false
      else
        true

  save: ->    
    data = new FormData
    data.append('company[slug]', @state.value)

    @setState({ sync: true, error: false })

    $.ajax
      url: @props.company_url
      data: data
      type: 'PUT'
      dataType: 'json'
      contentType:  false
      processData:  false

    .done @onSaveDone
    .fail @onSaveFail

  onSaveDone: (json) ->
    url = window.location.href
    parts = url.split('/')
    parts.pop()
    parts.pop()
    parts.push(@state.value)
    parts.push('settings')
    window.location.href = parts.join('/')
    # history.replaceState(null, document.title, parts.join('/'))

    @setState
      sync: false
      is_slug_valid: true

  onSaveFail: ->
    @setState
      sync: false
      error: true

  undoTyping: ->
    @setState
      value: ''
      error: false

  onKeyUp: (event) ->
    switch event.key
      when 'Enter'
        @save() unless @props.value == @state.value
      when 'Escape'
        @undoTyping()

  onClick: (event) ->
    @save() unless @props.value == @state.value

  onChange: (event) ->
    @setState({ value: event.target.value })

  onRemoveSlugChange: (event) ->
    @setState({ value: '', is_slug_valid: false })

# Exports
#
module.exports = Slug


# # @cjsx React.DOM

# # Imports
# #
# tag = React.DOM


# # Actions
# #
# CompanyActions = require('actions/company')


# # Functions
# #
# redirectFromTo = (fromURL, toURL) ->
#   window.location.href = window.location.href.replace(fromURL, toURL) if fromURL isnt toURL


# # Main
# #
# Component = React.createClass


#   hasSlug: ->
#     hasSlugErrors = @props.errors and @props.errors['slug'].length > 0
#     not hasSlugErrors and @props.company.slug and @props.company.slug.length > 0
  

#   isSlugValid: ->
#     @state.slug and @state.slug.length >= 3
  
  
#   update: (slug) ->
#     CompanyActions.update(@props.company.uuid, { slug: slug })


#   onSlugChange: (event) ->
#     @setState({ slug: event.target.value, errors: null })
  
  
#   onSaveClick: ->
#     @update(@state.slug)
  
  
#   onRemoveClick: ->
#     @update('')
  
  
#   componentWillReceiveProps: (nextProps) ->
#     @setState(@getStateFromProps(nextProps))
  
  
#   componentDidUpdate: (prevProps) ->
#     redirectFromTo(prevProps.company.url, @props.company.url)
  
  
#   getStateFromProps: (props) ->
#     slug:   props.company.slug || ''
#     errors: (props.errors || {})['slug']


#   getInitialState: ->
#     @getStateFromProps(@props)


#   render: ->
#     (tag.dl null,
#       (tag.dt null, 'Short URL')
#       (tag.dd null,
#         (tag.span null,
#           @props.url.split('//').pop() + '/'
#         )
        

#         (tag.input {
#           className:  'error' if @state.errors
#           onChange:   @onSlugChange
#           readOnly:   @hasSlug()
#           value:      @state.slug
#         })
        

#         (tag.button {
#           className:  'cc'
#           disabled:   !@isSlugValid() or @props.sync
#           onClick:    @onSaveClick
#         },
#           'Save'
#           (tag.i { className: 'fa fa-save' }) unless @props.sync
#           (tag.i { className: 'fa fa-spin fa-spinner' }) if @props.sync
#         ) unless @hasSlug()
        

#         (tag.button {
#           className:  'cc alert'
#           disabled:   @props.sync
#           onClick:    @onRemoveClick
#         },
#           'Remove'
#           (tag.i { className: 'fa fa-eraser' }) unless @props.sync
#           (tag.i { className: 'fa fa-spin fa-spinner' }) if @props.sync
#         ) if @hasSlug()
        
#       )
#     )


# # Exports
# #
# module.exports = Component
