# Expose
#
tag = React.DOM


# BR tag
#
br_tag = '<br />'


# Block level elements
#
blockLevelElements  = ['div', 'p']

isBlockLevelElement = (element) ->
  return false unless element and element.nodeType == 1
  return blockLevelElements.indexOf(element.tagName.toLowerCase()) > -1


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
    [(if isBlockLevelElement(node) and node.previousSibling then '\n' else ''), '']
  


# Normalize content
#
normalizeContentEditable = (node, root) ->
  root    = node unless root ; node.normalize() if node == root

  result  = switch node.nodeType

    # Element node
    when 1
      tagName = node.tagName.toLowerCase()

      if tagName == 'br' then br_tag else
        
        [prefix, suffix] = affixesForNode(node)
      
        children = Array.prototype.map.call node.childNodes, (child) -> normalizeContentEditable(child, root)
        
        "#{prefix}#{children.join('')}#{suffix}"
    
    # Text node
    when 3
      node.wholeText
  
  if node == root
    result = '' if result == br_tag
    result = result.split('\n').filter((part) -> part.length).map((part) -> "<div>#{part}</div>").join('')
  
  result


# ContentEditable Component
#
Component = React.createClass


  getDefaultProps: ->
    active:   true
    tagName:  'div'
  
  
  onInput: (event) ->
    content                 = normalizeContentEditable(event.target)
    @getDOMNode().innerHTML = '' if content.length == 0
  
  
  onBlur: (event) ->
    content                 = normalizeContentEditable(event.target)
    event.target.innerHTML  = content

    @props.onChange({ target: { value: content }}) if @props.onChange instanceof Function


  render: ->
    (tag[@props.tagName] {
      contentEditable:          @props.active
      onInput:                  @onInput
      onBlur:                   @onBlur
      dangerouslySetInnerHTML:  { __html: @props.value }
      'data-placeholder':       @props.placeholder
    })


# Expose
#
@cc.react.editor.ContentEditableComponent = Component
