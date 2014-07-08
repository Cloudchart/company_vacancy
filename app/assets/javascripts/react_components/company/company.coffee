#
#
tag = React.DOM


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
      people_url:         @props.people_url
      owner:              'company'
    
    
    (tag.article { className: 'company' },
      (HeaderComponent @props)
      (editorComponent)
    )


# Expose
#
@cc.react.company.Main = MainComponent
