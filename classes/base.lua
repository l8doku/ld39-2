
local class      = require 'lib.middleclass'
local Stateful   = require 'lib.stateful'
local cron       = require 'lib.cron'
local Base       = class("Base")
local tween      = require 'lib.tween'

Root.static.updateOrder = 9

Root.static.minBind = 20
Root.static.maxBind = 30

function Root:initialize(world, x, y, w, h)

    self.world = world

    self.doubleChance = 0.1
    self.x = x
    self.y = y
    self.w = w
    self.h = h

    self.hp = 8000
    self.isDead = false
    self.color = {128, 110, 86, 200}
    self.leadersToInvul = 8

    self.tweens = {}

    self.growthRate = 2.7
    self.maxBranches = 20
    self.branches = 0
    self.timer = {}
    self.timer.growth = cron.every(self.growthRate, self.growLeader, self)
    self.timer.growth:update(5.5)

    self.world:add(self, self.x, self.y, self.w, self.h)

end


function Root:update(dt)

    for i,v in pairs(self.timer) do
        v:update(dt)
    end

    for i,v in pairs(self.tweens) do
        if v.tween:update(dt) then
            if v.callback then v.callback() end
        end
    end

end

function Root:mousepressed()

end

function Root:mousereleased()

end

function Root:draw()

    lg.setColor(self.color)
    lg.rectangle("fill", self.x, self.y, self.w, self.h)
    lg.rectangle("line", self.x, self.y, self.w, self.h)

end

function Root:growLeader()
    self.branches = self.branches + 1
    local angle = love.math.random()*math.pi

    local r = love.math.random(Root.minBind, Root.maxBind)
    local dx = math.cos(angle) * r
    local dy = math.sin(angle) * r

    local leader = Leader:new(self.world, dx, dy, angle, self)


end

function Root:isInvincible()
    return numberOfLeaders >= self.leadersToInvul
end


function Root:takeHit(damage)
    if not self:isInvincible() then
        damage = damage or 0
        self.hp = self.hp - damage
        if self.hp <= 0 then
            self:destroy()
            youwin = true
            pause = true
        else
            self.color = {255, 0, 0, 255}
            self.tweens.flash = {}
            self.tweens.flash.tween = tween.new(0.2, self, {color = {128, 110, 86, 200}})
            end

    end
end

function Root:destroy()
    self.world:remove(self)
end

function Root:getCenter()
    return self.x + self.w/2, self.y + self.h/2
end

function Root:getLeftTopFromCenter(x, y)
    return x - self.w/2, y - self.h/2
end


function Root:getUpdateOrder()
   return self.class.updateOrder or self.updateOrder or 10000
end

return Root
