##= require ./Base

Base = cc.require('cc.stores.Base')


parseDate = (value) ->
  value = Date.parse(value) if _.isString(value)
  value = new Date(value)   if _.isNumber(value)
  value = null unless _.isDate(value)
  value


# Person Store
#
class PersonStore extends Base
  
  @displayName:       'PersonStore'
  

  parse_created_at: parseDate
  parse_updated_at: parseDate
  

# Exports
#
cc.module('cc.stores.PersonStore').exports = PersonStore
