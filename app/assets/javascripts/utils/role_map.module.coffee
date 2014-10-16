RoleMap = 
  owner:
    name: 'Creator'
  editor: 
    name: 'Editor'
    description: 'Allow to edit company'
    hint: 'Company HR managers or managing partners usually need access to editing.'
  trusted_reader: 
    name: 'Trusted'
    description: 'Allow to see financials'
    hint: 'View only access to company details and finances. Usually you\'d show it to investors like that.'
  public_reader:
    name: 'Viewer'
    description: 'View only'
    hint: 'Limited access, no finances, no details. Allows to see the company even if it\'s unlisted.'

module.exports = RoleMap
