lg = love.graphics
lm = love.mouse


local class = require 'lib.middleclass'
local Player = require 'classes.player'
local Bullet = require 'classes.bullet'
local Vine = require 'classes.vine'
local bump = require 'lib.bump'
local Root = require 'classes.root'
local Leader = require 'classes.leader'

--local Stateful = require 'lib.stateful'
--local Game = require 'classes.game.game'
--local loveframes = require("lib.loveframes")
local player

local ZaWarudo



local sortByUpdateOrder = function(a,b)
  return a:getUpdateOrder() < b:getUpdateOrder()
end




local cursor
local background


function love.load()
if arg[#arg] == "-debug" then require("mobdebug").start() end

    background = lg.newImage('images/background.png')
    cursor = lg.newImage('images/cursor.png')
    love.graphics.setLineWidth(2)
    ZaWarudo = bump.newWorld()
    numberOfLeaders = 0
    root = Root:new(ZaWarudo, 300, 100, 20, 40)


    lm.setVisible( false )
    lg.setBackgroundColor(190,190,190,255)
    player = Player:new(ZaWarudo)


end
--

function love.update(dt)
	if not pause then

        local l,t,w,h = -1000, -1000, love.graphics.getDimensions()
        local things, len = ZaWarudo:queryRect(l,t,w+1000,h+1000)

        table.sort(things, sortByUpdateOrder)

        for i=1, len do
            things[i]:update(dt)
        end

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
        player:mousepressed(x,y,button)
    end
end



function love.mousereleased(x, y, button)

end



function love.draw()

    lg.setColor(255,255,255)
    lg.draw(background)
    local     l,t,w,h = -1000, -1000, love.graphics.getDimensions()
    local things, len = ZaWarudo:queryRect(l, t, w + 1000, h + 1000)

    table.sort(things, sortByUpdateOrder)

    for i=1, len do
        things[i]:draw()
    end


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
