lg = love.graphics
lm = love.mouse

local class      = require 'lib.middleclass'
local Player     = require 'classes.player'
local bump       = require 'lib.bump'
local gamera     = require 'lib.gamera'
local Map        = require 'map.map'
local shakycam   = require 'lib.shakycam'
-- local Base       = require 'classes.base'

local Bullet     = require 'classes.bullet'


--local Stateful = require 'lib.stateful'
--local Game = require 'classes.game.game'
--local loveframes = require("lib.loveframes")
-- local player
local mainworld




local sortByUpdateOrder = function(a,b)
  return a:getUpdateOrder() < b:getUpdateOrder()
end

local drawDebug = true
local cursor
local background
local updateRadius

function love.load()
  if arg[#arg] == "-debug" then require("mobdebug").start() end

  updateRadius = 1000;
  background = lg.newImage('images/background.png')
  cursor = lg.newImage('images/cursor.png')
  love.graphics.setLineWidth(2)

  -- player = Player:new(mainworld)
  lg.setBackgroundColor(190,190,190,255)

  lm.setVisible( false )
  local width, height = 600*32, 100*32
  local gamera_cam = gamera.new(0,0, width, height)
  camera = shakycam.new(gamera_cam)
  -- camera:setScale(0.1)
  map    = Map:new(width, height, camera)

end
--

function love.update(dt)
	if not pause then

      -- Note that we only update elements that are visible to the camera. This is optional
      -- replace the map:update(dt, camera:getVisible()) with the following line to update everything
      -- map:update(dt)
      local l,t,w,h = camera:getVisible()
      l,t,w,h = l - updateRadius, t - updateRadius, w + updateRadius * 2, h + updateRadius * 2

      map:update(dt, l,t,w,h)
      camera:setPosition(map.player:getCenter())
      camera:update(dt)




        -- local l,t,w,h = -1000, -1000, love.graphics.getDimensions()
        -- local things, len = ZaWarudo:queryRect(l,t,w+1000,h+1000)
        --
        -- table.sort(things, sortByUpdateOrder)
        --
        -- for i=1, len do
        --     things[i]:update(dt)
        -- end

	end

end
--


function love.keypressed(key, unicode)
--  player:keypressed(key,unicode)
if key=="escape" then
		pause = not pause
	elseif (youlose or youwin) and key == "r" then
		love.load()
        pause = false
        youlose = false
        youwin = false

	end
end



function love.textinput(text)

end



function love.keyreleased(key, unicode)

end




function love.mousepressed(x, y, button)
    if not pause then
        -- player:mousepressed(x,y,button)
    end
end



function love.mousereleased(x, y, button)

end



function love.draw()


    lg.setColor(255,255,255)
    lg.draw(background)
    camera:draw(function(l,t,w,h)
      map:draw(drawDebug, l,t,w,h)
    end)
    -- local     l,t,w,h = -1000, -1000, love.graphics.getDimensions()
    -- local things, len = ZaWarudo:queryRect(l, t, w + 1000, h + 1000)

    -- table.sort(things, sortByUpdateOrder)

    -- for i=1, len do
        -- things[i]:draw()
    -- end


    if youlose then
		lg.setColor(0, 0, 0, 150)
		lg.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		lg.setColor(255, 255, 255)
		lg.setFont(player.guiFont)
		lg.printf(string.format("YOU\nLOST"), 0, 100, love.graphics.getWidth(), "center")
		lg.setFont(player.guiFont)
		lg.printf("PRESS R TO RESTART", 0, 200, love.graphics.getWidth(), "center")
	end

    if youwin then
		lg.setColor(0, 0, 0, 150)
		lg.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		lg.setColor(255, 255, 255)
		lg.setFont(player.guiFont)
		lg.printf(string.format("VICTORY"), 0, 100, love.graphics.getWidth(), "center")
		lg.setFont(player.guiFont)
		lg.printf("PRESS R TO RESTART", 0, 200, love.graphics.getWidth(), "center")
	end

    lg.setColor(255,255,255,100)
    local mx, my = lm.getPosition()
    local w, h = cursor:getDimensions()
    lg.draw(cursor, mx, my, 0, 1, 1, w/2, h/2)
end
