getSign = (n) -> 
  if n then (if n < 0 then -1 else 1) else 0


getCoordinates = (x01, y01, x02, y02, midpoint, radius) ->
  hRadius = Math.min(radius, Math.abs(x02 - x01) / 2)
  sign    = getSign(x02 - x01)
  
  x12 = x01 + hRadius * sign
  x22 = x02 - hRadius * sign
  
  y11 = Math.max(midpoint - radius, y01)
  y21 = Math.min(midpoint + radius, y02)
  
  x01:  x01
  y01:  y01
  x11:  x01
  y11:  y11
  x12:  x12
  y12:  midpoint
  x22:  x22
  y22:  midpoint
  x21:  x02
  y21:  y21
  x02:  x02
  y02:  y02


getPath = (coords) ->
  startPoint  = "M #{coords.x01} #{coords.y01}"
  startLine   = "L #{coords.x11} #{coords.y11}"
  startCurve  = "Q #{coords.x11} #{coords.y12} #{coords.x12} #{coords.y22}"
  middleLine  = "L #{coords.x22} #{coords.y22}"
  finishCurve = "Q #{coords.x21} #{coords.y22} #{coords.x21} #{coords.y21}"
  finishLine  = "L #{coords.x02} #{coords.y02}"
  
  "#{startPoint} #{startLine} #{startCurve} #{middleLine} #{finishCurve} #{finishLine}"
  

# Layout
#
Layout = (x1, y1, x2, y2, midpoint, radius = 10) ->
  getPath(getCoordinates(x1, y1, x2, y2, midpoint, radius))


# Exports
#
cc.module('blueprint/react/chart-preview/layout/link').exports = Layout
