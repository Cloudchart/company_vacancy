module.exports = (node) ->
  clone = node.cloneNode(true)

  deleteIds = (el) ->
    if el.hasChildNodes()
      child = el.firstChild
      while child
        if child.nodeType == 1
          deleteIds(child)
        child = child.nextSibling

    delete el.dataset.reactid

  deleteIds(clone)

  clone

  