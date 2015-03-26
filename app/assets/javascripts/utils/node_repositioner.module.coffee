module.exports =
  mixin: 

    repositionNodes: ->
      return unless parentNode = @getDOMNode()

      totalHeights = Immutable.Map()

      Immutable.Seq(parentNode.childNodes)
        .groupBy (node) ->
          node.getBoundingClientRect().left

        .forEach (nodes, j) ->
          totalHeights = totalHeights.set(j, 0)

          nodes.forEach (node, i) ->
            node.style.top  = 0

            bounds          = node.getBoundingClientRect()
            totalHeights    = totalHeights.set(j, totalHeights.get(j) + (bounds.bottom - bounds.top))

            return if i == 0

            prevNode        = nodes.get(i - 1)
            prevNodeBounds  = prevNode.getBoundingClientRect()

            delta           = bounds.top - prevNodeBounds.bottom

            node.style.top  = '-' + delta + 'px' unless delta == 0


      totalHeight = totalHeights.max()
      parentNode.style.height = totalHeight + 24 + 'px'

    componentDidMount: ->
      @repositionNodes()

      window.addEventListener 'resize', @repositionNodes

    componentWillUnmount: ->
      window.removeEventListener 'resize', @repositionNodes

    componentDidUpdate: ->
      @repositionNodes()