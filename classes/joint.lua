
local class = require 'lib.middleclass'
local Stateful = require 'lib.stateful'
local cron = require 'lib.cron'
local Joint = class("Joint"):include(Stateful)
local EnemyBullet = require 'classes.enemybullet'
local tween = require 'lib.tween'



local function randomFloat(min, max)
    return love.math.random()*(max-min) + min
end

Joint.static.minBind = 20
Joint.static.maxBind = 30
Joint.static.branchLengthMax = 6
Joint.static.bulletSpeed = 100
Joint.static.shootRate = 0.9
Joint.static.bounceRate = 0.2
Joint.static.image = lg.newImage('images/joint.png')
function Joint:initialize(parent)
    
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
    
    self.juice = {size = 1}
    self.color = {255, 255, 255, 255}
    
    self.timer = {}
  --  self.timer.shoot = cron.every(Vine.shootRate, self.shoot, self)
 --   self.timer.shoot:update(love.math.random()*Vine.shootRate)
    local randSize = randomFloat(0.9, 1.1)
    local randX = love.math.random(-2, 2)
    local randY = love.math.random(-2, 2)
    
    self.tweens = {}
    
    self.tweens.size = {}
    self.tweens.size.tween = tween.new(Joint.bounceRate, self.juice, {size = randSize}, 'inOutCubic')
    self.tweens.size.callback = function() 
                                    local randSize = randomFloat(0.9, 1.1)
                                    self.tweens.size.tween = tween.new(Joint.bounceRate, self.juice, {size = randSize}, 'inOutCubic')
                                end

    self.tweens.pos = {}
    self.tweens.pos.tween = tween.new(Joint.bounceRate, self, {dx = randX, dy = randY}, 'linear')
    self.tweens.pos.callback =  function()
                                    local randX = love.math.random(-2, 2)
                                    local randY = love.math.random(-2, 2)
                                    self.tweens.pos.tween = tween.new(Joint.bounceRate, self, {dx = randX, dy = randY}, 'linear')
                                end

    
    self.world:add(self, self.x, self.y, self.w, self.h)

end


function Joint:update(dt)
    
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

function Joint:mousepressed()
    
end

function Joint:mousereleased()
    
end

function Joint:draw()
    
    local scaleX = self.w/Joint.image:getWidth() * self.juice.size
    local scaleY = self.h/Joint.image:getHeight() * self.juice.size
    local offsetX = self.w * (self.juice.size - 1)/4
    local offsetY = self.h * (self.juice.size - 1)/4
    
    
    lg.setColor(self.color)
    lg.draw(Joint.image, self.x, self.y, self.juice.rotation or 0, scaleX, scaleY, offsetX, offsetY )
    
    
end


function Joint:shoot()
     local enemyBullet = EnemyBullet:new(self.world, self.x , self.y, 0, Joint.bulletSpeed)
end




function Joint:takeHit(damage)
    damage = damage or 0
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self:destroy()
    else
        self.color = {255, 0, 0, 255}
        self.tweens.flash = {}
        self.tweens.flash.tween = tween.new(0.2, self, {color = {255, 255, 255, 255}})
    end
    
end

function Joint:getCenter()
    return self.x + self.w/2, self.y + self.h/2
end

function Joint:getLeftTopFromCenter(x, y)
    return x - self.w/2, y - self.h/2
end

function Joint:alignWithParent()
    self.x, self.y = self:getLeftTopFromCenter(self.parent:getCenter())
    self.x = self.x + self.dx
    self.y = self.y + self.dy
end

function Joint:destroy()
    self.world:remove(self)
end


function Joint:getUpdateOrder()
   return self.class.updateOrder or self.updateOrder or 10000
end

return Joint












