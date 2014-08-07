##= require ../company/profile
##= require cloud_blueprint/react/chart_preview

# Expose
#
tag = React.DOM


CompanyProfileComponent = cc.require('react/company/profile')
ChartPreviewComponent   = cc.require('blueprint/react/chart-preview')



# Main component
#
# Properties:
#   sections:         all sections to render
#   sections_titles:  object sections titles
#   blocks:           all existing blocks
#   url:              url for ajax requests
#   object:           object key for ajax requests
#
MainComponent = React.createClass


  render: ->
    sectionsComponents = @props.sections.map (section) =>
      cc.react.editor.Section
        key:            section.key
        placeholder:    section.title
        title:          @props.sections_titles[section.key]
        url:            @props.url
        people_url:     @props.people_url
        vacancies_url:  @props.vacancies_url
        blocks_url:     @props.blocks_url
        owner:          @props.owner
        blocks:         @props.blocks.filter((block) -> block.section == section.key)
    
    sectionsComponents.splice(1, 0, CompanyProfileComponent({
      key:            'company-profile'
      url:            @props.url
      country:        @props.country
      industry_ids:   @props.industry_ids
      is_listed:      @props.is_listed
      short_name:     @props.short_name
    }))
    
    (tag.article { className: 'editor' },
      (cc.react.editor.SidebarComponent { blocks: @props.available_block_types })

      (tag.section {
        className: 'chart-preview-container'
      },
        ChartPreviewComponent({ id: @props.chart_ids[0], scale: 1 })
      ) if @props.chart_ids.length > 0

      (sectionsComponents)
    )


# Expose
#
#@cc.react.editor.Main = MainComponent
@cc.module('react/editor').exports = MainComponent
