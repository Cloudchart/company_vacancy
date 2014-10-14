###
  Used in:
  components/company/preview/list
###

tag = React.DOM

Logo = require('components/company/logo')

MainComponent = React.createClass

  getDefaultProps: ->
    { renderButtons: false }

  render: ->
    company = @props.company

    if company
      tag.article { className: "company-preview-2" },
        tag.a { href: company.meta.path },
          tag.header null,
            Logo {
              logoUrl: company.logotype_url
              value: company.name
            }
          tag.section { className: "middle" },
            tag.div { className: "left" },
              tag.div { className: "name" }, company.name
              tag.div { className: "description" }, company.description
            tag.div { className: "right" },
              tag.div { className: "size" },
                company.meta.people_count
                tag.i { className: "fa fa-male" }
              tag.div { className: "burn-rate" },
                "$300K"
                tag.span { className: "units" }, "month"
          tag.section { className: "bottom" },
            tag.p null, company.meta.tags.join(', ')
        if @props.renderButtons
          tag.div { className: "buttons" },
            tag.button { className: "cc decline" },
              "Decline"
              tag.i { className: "fa fa-close" }
            tag.button { className: "cc" },
              "Accept"
              tag.i { className: "fa fa-check" }
          
    else
      (tag.noscript null)


module.exports = MainComponent
