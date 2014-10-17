###
  Used in:

  cloud_blueprint/layouts/chart
  cloud_blueprint/react/chart_preview/layout/chart
###

# Second walk
second_walk = (v, m) ->
    v.x = v.__tree.prelim + m
    v.y = v.level
    _.each v.children, (w) -> second_walk(w, m + v.__tree.mod)


#Midpoint
midpoint = (v) ->
    leftmost_child  = _.first(v.children)
    rightmost_child = _.last(v.children)
    ((leftmost_child.__tree.prelim - leftmost_child.width / 2) + (rightmost_child.__tree.prelim + rightmost_child.width / 2)) / 2
    

# Next left node
next_left = (v) ->
    if _.isEmpty(v.children)
        v.__tree.thread
    else
        _.first(v.children)


# Next right node
next_right = (v) ->
    if _.isEmpty(v.children)
        v.__tree.thread
    else
        _.last(v.children)


# Move subtree
move_subtree = (wm, wp, shift) ->
    subtrees            = wp.__tree.index - wm.__tree.index
    wm.__tree.change   += shift / subtrees
    wp.__tree.change   -= shift / subtrees
    wp.__tree.prelim   += shift
    wp.__tree.shift    += shift
    wp.__tree.mod      += shift


# Ancestor
ancestor = (vim, v, default_ancestor) ->
    if vim.__tree.ancestor.parent == v.parent
        vim.__tree.ancestor
    else
        default_ancestor


# Execute shifts
execute_shifts = (v) ->
    shift   = 0
    change  = 0
    
    _.eachRight v.children, (w) ->
        w.__tree.prelim    += shift
        w.__tree.mod       += shift
        change             += w.__tree.change
        shift              += w.__tree.shift + change


# Tree traverse
traverse_with_callback = (node, callback, level = 0) ->
    _.each(node.children, (child) -> traverse_with_callback(child, callback, level + 1))
    callback(node, level)


#
#
#

layout = (root, options = {}) ->

    # First walk
    first_walk = (v) ->
        if v.children?.length > 0

            default_ancestor = v.children[0]

            for w in v.children
                first_walk(w)
                default_ancestor = apportion(w, default_ancestor)
    
            execute_shifts(v)
    
            if v.__tree.left_sibling?
                v.__tree.prelim = v.__tree.left_sibling.__tree.prelim + distance(v.__tree.left_sibling, v)
                v.__tree.mod = v.__tree.prelim - midpoint(v)
            else
                v.__tree.prelim = midpoint(v)

        else
            if v.__tree.left_sibling?
                v.__tree.prelim = v.__tree.left_sibling.__tree.prelim + distance(v.__tree.left_sibling, v)


    # Apportion
    apportion = (v, default_ancestor) ->
        if v.__tree.left_sibling?
            vip = v
            vop = v
            vim = v.__tree.left_sibling
            vom = vip.__tree.leftmost_sibling
        
            sip = vip.__tree.mod
            sop = vop.__tree.mod
            sim = vim.__tree.mod
            som = vom.__tree.mod
    
            while next_right(vim)? and next_left(vip)?
                vim = next_right(vim)
                vip = next_left(vip)
                vom = next_left(vom)
                vop = next_right(vop)
        
                vop.__tree.ancestor = v
        
                shift = (vim.__tree.prelim + sim) - (vip.__tree.prelim + sip) + distance(vim, vip)
        
                if shift > 0
                    move_subtree(ancestor(vim, v, default_ancestor), v, shift)
                    sip = sip + shift
                    sop = sop + shift
        
                sim = sim + vim.__tree.mod
                sip = sip + vip.__tree.mod
                som = som + vom.__tree.mod
                sop = sop + vop.__tree.mod
    
            if next_right(vim)? and !next_right(vop)?
                vop.__tree.thread   = next_right(vim)
                vop.__tree.mod     += sim - sop
    
            if next_left(vip)? and !next_left(vom)?
                vom.__tree.thread   = next_left(vip)
                vom.__tree.mod     += sip - som
                default_ancestor    = v

        default_ancestor


    # Distance
    distance = options.h_distance ? (wm, wp) -> if wm.parent == wp.parent then 1 else 2


    traverse_with_callback root, (node, level = 0) ->
        
        node.level  = level

        node.__tree =
            change:     0
            prelim:     0
            shift:      0
            mod:        0
            thread:     null
            ancestor:   node
        
        siblings                        = if node.parent? then node.parent.children else null

        node.__tree.index               = if siblings? then siblings.indexOf(node) else 0
        node.__tree.left_sibling        = if siblings? then siblings[node.__tree.index - 1] else null
        node.__tree.leftmost_sibling    = if siblings? then siblings[0] else null
    
    #

    first_walk(root)
    
    #
    
    second_walk(root, -root.__tree.prelim)

    #
    
    traverse_with_callback root, (node) -> delete node.__tree
    
    #
    
    root
    
    

#
#
#

_.extend @cc.blueprint.layouts,
    tree: layout
