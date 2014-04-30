class Node extends cc.blueprint.models.Base

  @attr_accessor('uuid', 'name')
  
  constructor: (attributes = {}) ->
    super(attributes)

#
#
#

_.extend cc.blueprint.models,
  Node: Node
