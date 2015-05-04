module.exports = 
  masonry: false

  domChildren: []

  initializeMasonry: (force) ->
    if !this.masonry || force
      this.masonry     = new window.Masonry(@getDOMNode())
      this.domChildren = @getNewDomChildren()

  getNewDomChildren: ->
    children = @getDOMNode().children

    Array.prototype.slice.call(children)

  diffDomChildren: ->
    oldChildren = @domChildren
    newChildren = @getNewDomChildren()

    removed = oldChildren.filter (oldChild) -> !~newChildren.indexOf(oldChild)

    added = newChildren.filter (newChild) -> !~oldChildren.indexOf(newChild)

    moved = []

    if removed.length == 0
      moved = oldChildren.filter (child, index) -> index != newChildren.indexOf(child)

    @domChildren = newChildren

    old: oldChildren
    new: newChildren
    removed: removed
    added: added
    moved: moved

  performLayout: ->
    diff = @diffDomChildren()

    if diff.removed.length > 0
      @masonry.remove(diff.removed)
      @masonry.reloadItems()

    if diff.added.length > 0
      @masonry.appended(diff.added)

    if diff.moved.length > 0
      @masonry.reloadItems()

    @masonry.layout()

  componentDidMount: ->
    @initializeMasonry()
    @performLayout()

  componentDidUpdate: ->
    @performLayout()
