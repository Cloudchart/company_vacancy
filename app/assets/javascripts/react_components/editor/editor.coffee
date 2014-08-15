##= require ../company/profile
##= require cloud_blueprint/react/chart_preview

# Expose
#
tag = React.DOM

CompanyProfileComponent = cc.require('react/company/profile')
ChartPreviewComponent   = cc.require('blueprint/react/chart-preview')

# Main component
#
MainComponent = React.createClass

  render: ->
    sectionsComponents = @props.sections.map (section) =>
      cc.react.editor.Section
        key:            section.key
        placeholder:    section.title
        title:          @props.sections_titles[section.key]
        company_url:    @props.company_url
        people_url:     @props.people_url
        vacancies_url:  @props.vacancies_url
        blocks_url:     @props.blocks_url
        owner:          @props.owner
        blocks:         @props.blocks.filter((block) -> block.section == section.key)
    
    sectionsComponents.splice(1, 0, CompanyProfileComponent({
      key:             'company-profile'
      company_url:     @props.company_url
      country:         @props.country
      industry_ids:    @props.industry_ids
      is_listed:       @props.is_listed
      short_name:      @props.short_name
      url:             @props.url
      is_url_verified: @props.is_url_verified
    }))
    
    (tag.article { className: 'editor' },
      (cc.react.editor.SidebarComponent { blocks: @props.available_block_types })

      (tag.section {
        className: 'chart-preview-container'
      },
        ChartPreviewComponent({ id: @props.chart_ids[0], scale: 1, company_id: @props.company_id })
      ) if @props.chart_ids.length > 0

      (sectionsComponents)
    )


# Expose
#
#@cc.react.editor.Main = MainComponent
@cc.module('react/editor').exports = MainComponent
