
local class = require 'lib.middleclass'
local Stateful = require 'lib.stateful'
local cron = require 'lib.cron'
local Enemy = class("Enemy"):include(Stateful)
local EnemyBullet = require 'classes.enemybullet'


Enemy.static.bindDistance = 100
local maxHp = 100
Enemy.static.bulletSpeed = 100
Enemy.static.shootRate = 0.9
function Enemy:initialize(world, x, y, w, h, parent)
    
    self.world = world
    self.parent = parent
    self.x = x
    self.y = y
    self.w = w
    self.h = h

    self.hp = maxHp
    

    self.shootRate = 0.9
    self.timer = {}
    
    self.timer.shoot = {}
    self.timer.shoot.timer = cron.every(self.shootRate, self.shoot, self)
    self.timer.shoot.active = true
    
    self.timer.shoot.timer:update(love.math.random()*self.shootRate)
    
    self.world:add(self, self.x, self.y, self.w, self.h)

end


function Enemy:update(dt)
    
    for i,v in pairs(self.timer) do
        if v.active then
            v.timer:update(dt)
        end
    end
end

function Enemy:mousepressed()
    
end

function Enemy:mousereleased()
    
end

function Enemy:draw()
    
    lg.setColor(Leader.color)
    lg.rectangle("fill", self.x, self.y, self.w, self.h)
    lg.rectangle("line", self.x, self.y, self.w, self.h)
    
    
end


function Enemy:shoot()
     local enemyBullet = EnemyBullet:new(self.world, self.x, self.y, 0, self.bulletSpeed)
end


function Enemy:takeHit(damage)
    damage = damage or 0
    self.hp = self.hp - damage
    if self.hp <= 0 then
        self:destroy()
    end
    
end

function Enemy:transformToVine()
    local vine = Vine:new(self.world, self.x, self.y, self.w, self.h)
    self:destroy()
end

function Enemy:destroy()
    self.world:remove(self)
end


function Enemy:getUpdateOrder()
   return self.class.updateOrder or 10000
end

return Enemy












