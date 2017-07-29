--[[
-- Block Class
-- This is the class that represents points of patrol of enemies

--]]
local class = require 'lib.middleclass'
local util  = require 'util'
local Entity = require 'classes.entity'

local Marker = class('Marker', Entity)

function Marker:initialize(world, l,t,w,h)
  Entity.initialize(self, world, l,t,w,h)
end

function Marker:getColor()
  return 220, 250, 150
end

function Marker:draw()
  local r,g,b = self:getColor()
  util.drawFilledRectangle(self.l, self.t, self.w, self.h, r,g,b)
end




function Marker:update(dt)
end

function Marker:destroy()
  Entity.destroy(self)

end

return Marker
