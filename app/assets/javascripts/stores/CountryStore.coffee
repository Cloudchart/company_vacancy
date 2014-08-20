##= require ./Base

Base = cc.require('cc.stores.Base')

# Country Store
#
class CountryStore extends Base
  
  @displayName:       'CountryStore'
  @unique_key:        'id'
  @attributesForSort: ['name']


# Exports
#
cc.module('cc.stores.CountryStore').exports = CountryStore
