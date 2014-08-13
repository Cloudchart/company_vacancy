##= require ./base

# Imports
#

BaseModel = cc.require('cc.models.BaseModel')


class CompanyModel extends BaseModel

  @className: 'Company'


#
#
cc.module('cc.models.Company').exports = CompanyModel
