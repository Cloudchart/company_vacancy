#
#
tag = React.DOM

# Section component
#

SectionComponent = React.createClass

  getInitialState: ->
    title: @props.value


  onChange: (event) ->
    @setState
      title: event.target.value
  
  
  onBlur: (event) ->
    @props.onTitleChange()


  render: ->
    (tag.section {},
      (tag.header { 'data-id': @props.key },
        (tag.input {
          type:         'text'
          autoComplete: 'off'
          placeholder:  @props.title
          value:        @state.title
          onChange:     @onChange
          onBlur:       @onBlur
        })
      )
    )

#
#
#

MainComponent = React.createClass

  
  handleTitleChange: ->
    sections = Object.keys(@refs).reduce(((memo, key) => memo[key] = @refs[key].title() ; memo), {})
    
    $.ajax
      url:      @props.url
      type:     'PUT'
      dataType: 'json'
      data:
        company:
          sections: sections


  render: ->
    sections = @props.sections.map (props) =>
      blocks              = @props.company_blocks.filter((block) -> block.section == props.key)
      props.ref           = props.key
      props.value         = @props.company.sections_titles[props.key]
      props.url           = @props.url
      props.onTitleChange = @handleTitleChange
      cc.react.editor.SectionComponent(props, blocks)
    
    (tag.article { className: 'editor' },
      sections
      @props.children
    )

# 
#
@cc.react.company.MainComponent = MainComponent
