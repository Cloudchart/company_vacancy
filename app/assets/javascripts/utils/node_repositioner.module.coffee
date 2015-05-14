module.exports =
  mixin: 

    repositionNodes: ->
      return unless parentNode = @getDOMNode()

      # TODO
      # Quick solution, but relying on timeout is not good
      # better find something better later
      setTimeout ->
        if parentNode.childNodes.length > 0
          columnsHeights = Immutable.Map()

          Immutable.Seq(parentNode.childNodes)
            .groupBy (node) ->
              node.getBoundingClientRect().left

            .forEach (nodes, j) ->
              columnsHeights = columnsHeights.set(j, 0)

              nodes.forEach (node, i) ->
                node.style.top  = 0

                bounds          = node.getBoundingClientRect()
                columnsHeights  = columnsHeights.set(j, columnsHeights.get(j) + (bounds.height))
                return if i == 0

                prevNode        = nodes.get(i - 1)
                prevNodeBounds  = prevNode.getBoundingClientRect()

                delta           = bounds.top - prevNodeBounds.bottom

                node.style.top  = '-' + delta + 'px' unless delta == 0

          maxColumnHeight = columnsHeights.max()
          parentNode.style.height = maxColumnHeight + 24 + 'px'
      , 100

    imagesLoaded: ->
      window.imagesLoaded @getDOMNode(), (instance) =>
        @repositionNodes()

    componentDidMount: ->
      @repositionNodes()
      @imagesLoaded()

      window.addEventListener 'resize', @repositionNodes

    componentWillUnmount: ->
      window.removeEventListener 'resize', @repositionNodes

    componentDidUpdate: ->
      @repositionNodes()
      @imagesLoaded()