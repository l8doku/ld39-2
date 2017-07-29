
local class = require 'lib.middleclass'
local Stateful = require 'lib.stateful'
local cron = require 'lib.cron'
local Vine = class("Vine"):include(Stateful)
local EnemyBullet = require 'classes.enemybullet'
local tween = require 'lib.tween'

local function randomFloat(min, max)
    return love.math.random()*(max-min) + min
end


Vine.static.hitSound = love.audio.newSource('sounds/vine_hit.wav')
Vine.static.minBind = 20
Vine.static.maxBind = 50
Vine.static.branchLengthMax = 6
Vine.static.bulletSpeed = 100
Vine.static.shootRate = 0.9
Vine.static.bounceRate = 0.2
Vine.static.image = lg.newImage('images/vine.png')
function Vine:initialize(parent)
    
    self.world = parent.world
    
    self.w = parent.w
    self.h = parent.h
    self.updateOrder = parent.updateOrder
    self.dx = 0
    self.dy = 0
    self.speed = 100
    self.parent = parent
    self:alignWithParent()
    self.hp = 150
    
    self.juice = {size = 1, rotation = 0}
    self.color = {255, 255, 255, 255}
    
    self.timer = {}
  --  self.timer.shoot = cron.every(Vine.shootRate, self.shoot, self)
 --   self.timer.shoot:update(love.math.random()*Vine.shootRate)
    local randSize = randomFloat(0.9, 1.1)
    local randAngle = randomFloat(-0.1, 0.1)
    local randX = love.math.random(-2, 2)
    local randY = love.math.random(-2, 2)
    
    self.tweens = {}
    
    self.tweens.size = {}
    self.tweens.size.tween = tween.new(Vine.bounceRate, self.juice, {size = randSize}, 'inOutCubic')
    self.tweens.size.callback = function() 
                                    local randSize = randomFloat(0.9, 1.1)
                                    self.tweens.size.tween = tween.new(Vine.bounceRate, self.juice, {size = randSize}, 'inOutCubic')
                                end
                                
    self.tweens.rotation = {}
    self.tweens.rotation.tween = tween.new(Vine.bounceRate, self.juice, {rotation = randAngle}, 'inOutCubic')
    self.tweens.rotation.callback = function() 
                                    local randAngle = randomFloat(-0.1, 0.1)
                                    self.tweens.rotation.tween = tween.new(Vine.bounceRate, self.juice, {rotation = randAngle}, 'inOutCubic')
                                end
    

    self.tweens.pos = {}
    self.tweens.pos.tween = tween.new(Vine.bounceRate, self, {dx = randX, dy = randY}, 'linear')
    self.tweens.pos.callback =  function()
                                    local randX = love.math.random(-2, 2)
                                    local randY = love.math.random(-2, 2)
                                    self.tweens.pos.tween = tween.new(Vine.bounceRate, self, {dx = randX, dy = randY}, 'linear')
                                end

    
    self.world:add(self, self.x, self.y, self.w, self.h)

end


function Vine:update(dt)
    
    self:alignWithParent()
    
    for i,v in pairs(self.timer) do
        v:update(dt)
    end
    
    for i,v in pairs(self.tweens) do
        if v.tween:update(dt) then
            if v.callback then v.callback() end
        end
    end
    
    
    
--    if self.tweens.size:update(dt) then
--        local randSize = randomFloat(0.9, 1.1)
--        self.tween.size = tween.new(Vine.bounceRate, self.juice, {size = randSize}, 'inOutCubic')
        
--    end
    
--    if self.tween.pos:update(dt) then
--        local randX = love.math.random(-10, 10)
--        local randY = love.math.random(-10, 10)
--        self.tween.pos = tween.new(Vine.bounceRate, self, {dx = randX, dy = randY}, 'linear')
--    end
    
    

    
end

function Vine:mousepressed()
    
end

function Vine:mousereleased()
    
end

function Vine:draw()
    
    local scaleX = self.w/Vine.image:getWidth() * self.juice.size
    local scaleY = self.h/Vine.image:getHeight() * self.juice.size
    local offsetX = self.w * (self.juice.size - 1)/4
    local offsetY = self.h * (self.juice.size - 1)/4
    
    
    lg.setColor(self.color)
    lg.draw(Vine.image, self.x, self.y, self.juice.rotation or 0, scaleX, scaleY, offsetX, offsetY )
    
    
end


function Vine:shoot()
     local enemyBullet = EnemyBullet:new(self.world, self.x , self.y, 0, Vine.bulletSpeed)
end




function Vine:takeHit(damage)
    damage = damage or 0
    self.hp = self.hp - damage
     local pewpew = Vine.hitSound:clone()
        pewpew:play()
    if self.hp <= 0 then
        self:destroy()
    else
        self.color = {255, 0, 0, 255}
        self.tweens.flash = {}
        self.tweens.flash.tween = tween.new(0.2, self, {color = {255, 255, 255, 255}})
    end
    
end

function Vine:getCenter()
    return self.x + self.w/2, self.y + self.h/2
end

function Vine:getLeftTopFromCenter(x, y)
    return x - self.w/2, y - self.h/2
end

function Vine:alignWithParent()
    self.x, self.y = self:getLeftTopFromCenter(self.parent:getCenter())
    self.x = self.x + self.dx
    self.y = self.y + self.dy
end

function Vine:destroy()
    self.world:remove(self)
end


function Vine:getUpdateOrder()
   return self.class.updateOrder or self.updateOrder or 10000
end

return Vine












