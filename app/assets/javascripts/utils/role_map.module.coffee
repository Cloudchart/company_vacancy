RoleMap = 
  Company:
    owner:
      name: 'Creator'
    editor: 
      name: 'Editor'
      description: 'Allow to edit company'
      hint: 'Company HR managers or managing partners usually need access to editing.'
      header: "company, chart, financials and allow to edit"
    trusted_reader: 
      name: 'Trusted'
      description: 'Allow to see financials'
      hint: 'View only access to company details and finances. Usually you\'d show it to investors like that.'
      header: "company, chart and financials"
    public_reader:
      name: 'Viewer'
      description: 'View only'
      hint: 'Limited access, no finances, no details. Allows to see the company even if it\'s unlisted.'
      header: "company and chart"
  Pinboard:
    owner:
      name: 'Owner'
    editor: 
      name: 'Editor'
      description: 'Editor'
      hint: 'Can edit collection settings, add or remove insights, invite other users'
      # header: "and allow to edit"
    contributor:
      name: 'Contributor'
      description: 'Contributor'
      hint: "Can add insights, can't remove them or invite other users"
      # header:
    reader:
      name: 'Reader'
      description: 'Reader'
      hint: 'Read-only access'
      # header: "collection"

module.exports = RoleMap
