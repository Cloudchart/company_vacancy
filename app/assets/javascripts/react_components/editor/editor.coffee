##= require cloud_blueprint/react/chart_preview

# Expose
#
tag = React.DOM

ChartPreviewComponent   = cc.require('blueprint/react/chart-preview')

# Main component
#
MainComponent = React.createClass

  render: ->
    sectionsComponents = @props.available_sections.map (section) =>
      cc.react.editor.Section
        key:            section.key
        placeholder:    section.title
        title:          @props.sections[section.key]
        company_url:    @props.company_url
        people_url:     @props.people_url
        vacancies_url:  @props.vacancies_url
        blocks_url:     @props.blocks_url
        owner:          @props.owner
        blocks:         @props.blocks.filter((block) -> block.section == section.key)
    
    (tag.article { className: 'editor' },
      (cc.react.editor.SidebarComponent { blocks: @props.available_block_types })

      (tag.section {
        className: 'chart-preview-container'
      },
        ChartPreviewComponent
          id: @props.charts[0].uuid
          permalink: @props.charts[0].permalink
          company_id: @props.id
          scale: 1
      ) if @props.charts.length > 0

      (sectionsComponents)
    )

# Expose
#
@cc.module('react/editor').exports = MainComponent
