local util = {}

util.drawFilledRectangle = function(l,t,w,h, r,g,b)
  r = r or 255
  g = g or 0
  b = b or 0
  love.graphics.setColor(r,g,b,100)
  love.graphics.rectangle('fill', l,t,w,h)
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle('line', l,t,w,h)
end

util.getCenter = function(l,t,w,h)
    return l + w/2, t + h/2
end


util.sortByUpdateOrder = function(a,b)
  return a:getUpdateOrder() < b:getUpdateOrder()
end

util.sortByCreatedAt = function(a,b)
  return a.created_at < b.created_at
end


return util
