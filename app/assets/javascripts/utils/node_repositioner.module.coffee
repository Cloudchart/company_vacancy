module.exports =
  mixin: 

    repositionNodes: ->
      return unless parentNode = @getDOMNode()

      Immutable.Seq(parentNode.childNodes)
        .groupBy (node) ->
          node.getBoundingClientRect().left

        .forEach (nodes) ->
          nodes.forEach (node, i) ->
            node.style.top  = 0

            return if i == 0

            bounds          = node.getBoundingClientRect()
            prevNode        = nodes.get(i - 1)
            prevNodeBounds  = prevNode.getBoundingClientRect()

            delta           = bounds.top - prevNodeBounds.bottom

            node.style.top  = '-' + delta + 'px' unless delta == 0

    componentDidMount: ->
      @repositionNodes()

      window.addEventListener 'resize', @repositionNodes

    componentWillUnmount: ->
      window.removeEventListener 'resize', @repositionNodes

    componentDidUpdate: ->
      @repositionNodes()