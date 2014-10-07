# BR tag
#
br_tag = '<br />'


# Block level elements
#
blockLevelElements  = ['div', 'p']

isBlockLevelElement = (tagName) ->
  return _.contains blockLevelElements, tagName


# Allowed element
#
allowedTagNames     = ['b', 'i', 'strong']

isAllowedTagName    = (tagName) ->
  return allowedTagNames.indexOf(tagName) > -1


# Affixes for node
#
affixesForNode = (node) ->
  tagName = node.tagName.toLowerCase()

  if isAllowedTagName(tagName)
    ["<#{tagName}>", "</#{tagName}>"]
  else
    [(if isBlockLevelElement(tagName) and node.previousSibling then '\n' else ''), '']


sanitize = (node, rootNode = node) ->
  node.normalize() if node == rootNode
  
  content = switch node.nodeType
  
    when 1 # Element Node
      tagName = node.tagName.toLowerCase()

      if tagName == 'br'
        br_tag
      else
        [prefix, suffix]  = affixesForNode(node)
        children          = _.map node.childNodes, (childNode) -> sanitize(childNode, rootNode)
        "#{prefix}#{children.join('')}#{suffix}"
    
    when 3 # Text Node
      node.wholeText
  
  if node == rootNode
    content = '' if content == br_tag

    content = _.chain(content.split('\n'))
      .filter (part) -> part.length
      .map (part) -> "<div>#{part}</div>"
      .join ''
      .value()
  
  content


# Exports
#
module.exports = sanitize
