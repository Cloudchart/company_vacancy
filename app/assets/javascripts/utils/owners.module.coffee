OwnerStores =
  'Company':     require('stores/company_store.cursor')
  'Pinboard':    require('stores/pinboard_store')

OwnerNames = 
  'Company':  'company'
  'Pinboard': 'collection'

module.exports = 
  getName: (ownerType) -> OwnerNames[ownerType]
  getStore: (ownerType) -> OwnerStores[ownerType]