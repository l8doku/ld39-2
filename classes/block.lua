--[[
-- Block Class
-- This is the class that represents the walls, floors and "rocks" in the Demo.
-- * A "breakable" rock is brown, while an "indestructible" one is blue
-- * When a rock is destroyed, it spawns some debris
--]]
local class = require 'lib.middleclass'
local util  = require 'util'
local Entity = require 'classes.entity'

local Block = class('Block', Entity)

function Block:initialize(world, l,t,w,h)
  Entity.initialize(self, world, l,t,w,h)
end

function Block:getColor()
  return 220, 150, 150
end

function Block:draw()
  local r,g,b = self:getColor()
  util.drawFilledRectangle(self.l, self.t, self.w, self.h, r,g,b)
end

function Block:update(dt)
end

function Block:destroy()
  Entity.destroy(self)
end

return Block
