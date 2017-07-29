local class = require 'lib.middleclass'
local Stateful = require 'lib.stateful'
local Game = require 'classes.game.game'
local loveframes = require("lib.loveframes")

local game

function love.load()
if arg[#arg] == "-debug" then require("mobdebug").start() end
  game = Game:new()
end
--

function love.update(dt)
  game:update(dt)
  loveframes.update(dt)
end
--
    
    
function love.keypressed(key, unicode)
    loveframes.keypressed(key, unicode)
end



function love.textinput(text)
loveframes.textinput(text)
end



function love.keyreleased(key, unicode)
    loveframes.keyreleased(key)
end




function love.mousepressed(x, y, button)
    game:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end



function love.mousereleased(x, y, button)
    game:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end



function love.draw()
    game:draw();
    loveframes.draw()
    love.graphics.setColor(255,255,255,150);
    for i=0,love.window.getWidth(),100 do
        love.graphics.line(i, 0, i, love.window.getHeight())
    end   
    for i=0,love.window.getHeight(),100 do
        love.graphics.line(0, i, love.window.getWidth(), i)
    end
end