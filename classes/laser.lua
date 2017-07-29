
local class = require 'lib.middleclass'
local Stateful = require 'lib.stateful'
local Laser = class("Laser"):include(Stateful)
local cron = require 'lib.cron'
local tween = require 'lib.tween'


local function randomFloat(min, max)
    return love.math.random()*(max-min) + min
end

Laser.static.updateOrder = 120
Laser.static.sounds = {}
Laser.static.sounds[1] = love.audio.newSource('sounds/laser.wav', 'static')
Laser.static.sounds[2] = love.audio.newSource('sounds/laser2.wav', 'static')
Laser.static.sounds[3] = love.audio.newSource('sounds/laser3.wav', 'static')
Laser.static.sounds[4] = love.audio.newSource('sounds/laser4.wav', 'static')

function Laser:initialize(world, x, y)

    self.world = world
    self.w = 10
    self.h = 1000
    self.x = x - self.w/2
    self.y = y - self.h
    self.damage = 200
    
    self.size = 1
    self.timeToLive = 0.3

    
    self.tweens = {}
    
    self.tweens.size = {}
    self.tweens.size.tween = tween.new(self.timeToLive, self, {size = 0}, 'outQuad')
    self.tweens.size.callback = function() 
                                    self:destroy()
                                end

    
    self.world:add(self, self.x, self.y, self.w, self.h)
    local actualX, actualY, cols, len = self.world:check(self, self.x, self.y, self.filter)
    for i=1,len do
        cols[i].other:takeHit(self.damage)
    end
    local pewpew = Laser.sounds[love.math.random(1,#Laser.sounds)]:clone()
    pewpew:play()
end


function Laser:update(dt)
    

    
    for i,v in pairs(self.tweens) do
        if v.tween:update(dt) then
            if v.callback then v.callback() end
        end
    end
    
end

function Laser:mousepressed()
    
end
    
function Laser:mousereleased()
    
end

function Laser:draw()
    lg.setColor(255, 255, 255, 200)
    local width = self.w * self.size
    
    lg.rectangle("fill", self.x, self.y, width, self.h)
end





function Laser:destroy()
    
    self.world:remove(self)
end


function Laser:filter(other)
  local kind = other.class.name
  if kind == 'Vine' or kind == 'Leader' or kind == 'Root' then return 'cross' end
end

function Laser:getUpdateOrder()
   return self.class.updateOrder or self.updateOrder or 10000
end

return Laser
