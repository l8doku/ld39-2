--[[
-- Block Class
-- This is the class that represents the walls, floors and "rocks" in the Demo.
-- * A "breakable" rock is brown, while an "indestructible" one is blue
-- * When a rock is destroyed, it spawns some debris
--]]
local class = require 'lib.middleclass'
local util  = require 'util'
local Entity = require 'classes.entity'

local Goal = class('Goal', Entity)

function Goal:initialize(world, l,t,w,h)
  Entity.initialize(self, world, l,t,w,h)
end

function Goal:getColor()
  return 150, 150, 220
end

function Goal:draw()
  local r,g,b = self:getColor()
  util.drawFilledRectangle(self.l, self.t, self.w, self.h, r,g,b)
end

function Goal:update(dt)
end

function Goal:destroy()
  Entity.destroy(self)



end

return Goal
