# Imports
#
tag = React.DOM


# Actions
#
CompanyActions = require('actions/company')


# Functions
#
redirectFromTo = (fromURL, toURL) ->
  window.location.href = window.location.href.replace(fromURL, toURL) if fromURL isnt toURL


# Main
#
Component = React.createClass


  hasSlug: ->
    hasSlugErrors = @props.errors and @props.errors['slug'].length > 0
    not hasSlugErrors and @props.company.slug and @props.company.slug.length > 0
  

  isSlugValid: ->
    @state.slug and @state.slug.length >= 3
  
  
  update: (slug) ->
    CompanyActions.update(@props.company.uuid, { slug: slug })


  onSlugChange: (event) ->
    @setState({ slug: event.target.value, errors: null })
  
  
  onSaveClick: ->
    @update(@state.slug)
  
  
  onRemoveClick: ->
    @update('')
  
  
  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromProps(nextProps))
  
  
  componentDidUpdate: (prevProps) ->
    redirectFromTo(prevProps.company.url, @props.company.url)
  
  
  getStateFromProps: (props) ->
    slug:   props.company.slug || ''
    errors: (props.errors || {})['slug']


  getInitialState: ->
    @getStateFromProps(@props)


  render: ->
    (tag.dl null,
      (tag.dt null, 'Short URL')
      (tag.dd null,
        (tag.span null,
          @props.url.split('//').pop() + '/'
        )
        

        (tag.input {
          className:  'error' if @state.errors
          onChange:   @onSlugChange
          readOnly:   @hasSlug()
          value:      @state.slug
        })
        

        (tag.button {
          className:  'cc'
          disabled:   !@isSlugValid() or @props.sync
          onClick:    @onSaveClick
        },
          'Save'
          (tag.i { className: 'fa fa-save' }) unless @props.sync
          (tag.i { className: 'fa fa-spin fa-spinner' }) if @props.sync
        ) unless @hasSlug()
        

        (tag.button {
          className:  'cc alert'
          disabled:   @props.sync
          onClick:    @onRemoveClick
        },
          'Remove'
          (tag.i { className: 'fa fa-eraser' }) unless @props.sync
          (tag.i { className: 'fa fa-spin fa-spinner' }) if @props.sync
        ) if @hasSlug()
        
      )
    )


# Exports
#
module.exports = Component
