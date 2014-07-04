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

MainComponents = React.createClass

  
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


# Company Header component
#
HeaderComponent = React.createClass

  gatherSections: ->
    @props.available_sections.map (section) ->
      (tag.a {
        key:  section.title
        href: "##{section.title}"
      }, section.title)

  render: ->
    (tag.header {},
      (tag.aside { className: 'logo' },
        (tag.i { className: 'fa fa-magic' })
      )
      (tag.h1   {},
        @props.name
        (tag.small {}, @props.description)
      )
      (tag.nav  {}, @gatherSections())
    )


# Company Main component
#
MainComponent = React.createClass

  render: ->
    editorComponent = cc.react.editor.Main
      sections:           @props.available_sections
      sections_titles:    @props.sections
      blocks:             @props.blocks
      url:                @props.url
      owner:              'company'
    
    
    (tag.article { className: 'company' },
      (HeaderComponent @props)
      (editorComponent)
    )

# Expose
#
@cc.react.company.Main = MainComponent
