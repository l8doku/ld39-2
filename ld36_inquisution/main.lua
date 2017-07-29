lg = love.graphics
lm = love.mouse


local class      = require 'lib.middleclass'
local Player     = require 'classes.player'
local bump       = require 'lib.bump'
local gamera     = require 'lib.gamera'
local Map        = require 'map'

local updateRadius = 1000 -- how "far away from the camera" things stop being updated
local drawDebug   = false  -- draw bump's debug info, fps and memory


local camera, map

---------------------------------------------------------------------------------------------------------
function love.load()
if arg[#arg] == "-debug" then require("mobdebug").start() end

    love.graphics.setLineWidth(2)

    lg.setBackgroundColor(190,190,190,255)


    local width, height = 600*32, 100*32
    camera = gamera.new(0,0, width, height)
  --  camera:setScale(0.1)
    map    = Map:new(width, height, camera)
end
--



-------------------------------------------------------------------------------------------------- Updating
function love.update(dt)
  if dt > 0.5 then dt = 0.5 end
  -- Note that we only update elements that are visible to the camera. This is optional
  -- replace the map:update(dt, camera:getVisible()) with the following line to update everything
  -- map:update(dt)
  local l,t,w,h = camera:getVisible()
  l,t,w,h = l - updateRadius, t - updateRadius, w + updateRadius * 2, h + updateRadius * 2

  map:update(dt, l,t,w,h)
  local cx, cy = map.player:getCenter()
  local mx, my = love.mouse.getPosition()
  mx, my = camera:toWorld(mx, my)
  local mouseLookWeight = 0.2
  camera:setPosition(cx*(1 - mouseLookWeight) + mx * mouseLookWeight, cy*(1 - mouseLookWeight) + my * mouseLookWeight)

end

--------------------------------------------------------------------------------------------------- Drawing
function love.draw()

  camera:draw(function(l,t,w,h)
    l,t,w,h = l - updateRadius, t - updateRadius, w + updateRadius * 2, h + updateRadius * 2

    map:draw(l,t,w,h)
  end)

  love.graphics.setColor(255, 255, 255)

  local w,h = love.graphics.getDimensions()


end

-- Non-player keypresses
-----------------------------------------------------------------------------------------------------------
function love.keypressed(k)
  if k=="escape" then love.event.quit() end
  if k=="tab"    then drawDebug = not drawDebug end
  if k=="delete" then
    collectgarbage("collect")
  end
  if k=="return" then
    map:reset()
  end
end
