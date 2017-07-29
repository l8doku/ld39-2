
local class = require 'lib.middleclass'
local Stateful = require 'lib.stateful'
local cron = require 'lib.cron'
local Leader = class("Leader"):include(Stateful)
local EnemyBullet = require 'classes.enemybullet'
local Vine = require 'classes.vine'
local Joint = require 'classes.joint'

local pi = math.pi
Leader.static.patterns = {}
Leader.static.patterns[1] = {}
Leader.static.patterns[1][1] = {angle = 80 * pi/180, delay = 0}
Leader.static.patterns[1][2] = {angle = 90 * pi/180, delay = 0}
Leader.static.patterns[1][3] = {angle = 100 * pi/180, delay = 0}
Leader.static.patterns[1][4] = {angle = 80 * pi/180, delay = 0.2}
Leader.static.patterns[1][5] = {angle = 90 * pi/180, delay = 0.2}
Leader.static.patterns[1][6] = {angle = 100 * pi/180, delay = 0.2}
Leader.static.patterns[1][7] = {angle = 80 * pi/180, delay = 0.4}
Leader.static.patterns[1][8] = {angle = 90 * pi/180, delay = 0.4}
Leader.static.patterns[1][9] = {angle = 100 * pi/180, delay = 0.4}
Leader.static.patterns[1][10] = {angle = 80 * pi/180, delay = 0.6}
Leader.static.patterns[1][11] = {angle = 90 * pi/180, delay = 0.6}
Leader.static.patterns[1][12] = {angle = 100 * pi/180, delay = 0.6}
Leader.static.patterns[1][13] = {angle = 80 * pi/180, delay = 0.8}
Leader.static.patterns[1][14] = {angle = 90 * pi/180, delay = 0.8}
Leader.static.patterns[1][15] = {angle = 100 * pi/180, delay = 0.8}

Leader.static.patterns[2] = {}
Leader.static.patterns[2][1] = {angle = 90 * pi/180, delay = 0}
Leader.static.patterns[2][2] = {angle = 85 * pi/180, delay = 0.1}
Leader.static.patterns[2][3] = {angle = 80 * pi/180, delay = 0.2}
Leader.static.patterns[2][4] = {angle = 85 * pi/180, delay = 0.3}
Leader.static.patterns[2][5] = {angle = 90 * pi/180, delay = 0.4}
Leader.static.patterns[2][6] = {angle = 95 * pi/180, delay = 0.5}
Leader.static.patterns[2][7] = {angle = 100 * pi/180, delay = 0.6}
Leader.static.patterns[2][8] = {angle = 95 * pi/180, delay = 0.7}
Leader.static.patterns[2][9] = {angle = 90 * pi/180, delay = 0.8}
Leader.static.patterns[2][10] = {angle = 85 * pi/180, delay = 0.9}
Leader.static.patterns[2][11] = {angle = 80 * pi/180, delay = 1}
Leader.static.patterns[2][12] = {angle = 85 * pi/180, delay = 1.1}
Leader.static.patterns[2][13] = {angle = 90 * pi/180, delay = 1.2}
Leader.static.patterns[2][14] = {angle = 95 * pi/180, delay = 1.3}
Leader.static.patterns[2][15] = {angle = 100 * pi/180, delay = 1.4}
Leader.static.patterns[2][16] = {angle = 95 * pi/180, delay = 1.5}
Leader.static.patterns[2][17] = {angle = 90 * pi/180, delay = 1.6}


Leader.static.patterns[3] = {}
Leader.static.patterns[3][1] = {angle = 70 * pi/180, delay = 0}
Leader.static.patterns[3][2] = {angle = 73 * pi/180, delay = 0}
Leader.static.patterns[3][3] = {angle = 76 * pi/180, delay = 0}
Leader.static.patterns[3][4] = {angle = 79 * pi/180, delay = 0}
Leader.static.patterns[3][5] = {angle = 82 * pi/180, delay = 0}
Leader.static.patterns[3][6] = {angle = 85 * pi/180, delay = 0}
Leader.static.patterns[3][7] = {angle = 88 * pi/180, delay = 0}
Leader.static.patterns[3][8] = {angle = 91 * pi/180, delay = 0}
Leader.static.patterns[3][9] = {angle = 94 * pi/180, delay = 0}
Leader.static.patterns[3][10] = {angle = 97 * pi/180, delay = 0}
Leader.static.patterns[3][11] = {angle = 100 * pi/180, delay = 0}
Leader.static.patterns[3][12] = {angle = 103 * pi/180, delay = 0}
Leader.static.patterns[3][13] = {angle = 106 * pi/180, delay = 0}
Leader.static.patterns[3][14] = {angle = 109 * pi/180, delay = 0}



Leader.static.minBind = 15
Leader.static.maxBind = 20
Leader.static.branchLengthMax = 10
Leader.static.color = {80, 80, 150, 150}
Leader.static.hitSound = love.audio.newSource('sounds/leader_hit.wav')
function Leader:initialize(world, dx, dy, angle, parent) -- dx, dy - offset from center of the parent
    
    local w = love.math.random(15, 30)
    local h = love.math.random(15, 30)
    
    
    numberOfLeaders = numberOfLeaders + 1
    self.world = world
    
    self.parent = parent
    
    self.growthAngle = angle
    self.dx = dx
    self.dy = dy
    self.w = w
    self.h = h
    self.jointChance = 0.1
    self:alignWithParent()
    self.updateOrder = math.floor(angle*1000) 
    

    self.bindDistance = 100
    self.speed = 100
    self.branchLength = parent.branchLength or 0;
    self.branchLength = self.branchLength + 1
        
    self.hp = 400
    
    
    self.bulletSpeed = 50
    
    self.growthRate = 0.3
    self.shootRate = 6
    self.timer = {}
    if self.branchLength < Leader.branchLengthMax then
        self.timer.growth = {}
        self.timer.growth.timer = cron.after(self.growthRate, self.growVine, self)
        self.timer.growth.active = true
    end
    
    self.timer.shoot = {}
    self.timer.shoot.timer = cron.every(self.shootRate, self.shootPattern, self)
    self.timer.shoot.active = true
    
    self.timer.shoot.timer:update(love.math.random()*self.shootRate*4/6)
    
    self.world:add(self, self.x, self.y, self.w, self.h)
    
    

end


function Leader:update(dt)
    
    self:alignWithParent()
    
    for i,v in pairs(self.timer) do
        if v.active then
            v.timer:update(dt)
        end
    end
    
end

function Leader:mousepressed()
    
end

function Leader:mousereleased()
    
end

function Leader:draw()
    
    lg.setColor(Leader.color)
    lg.rectangle("fill", self.x, self.y, self.w, self.h)
    lg.rectangle("line", self.x, self.y, self.w, self.h)
    
    local x, y = self:getCenter()
    local rx, ry = root:getCenter()
    
    if root:isInvincible() then
        lg.setColor(200,200,200)
    else
        lg.setColor(200,50,50)
    end
    
    lg.line(x, y, rx, ry)
    
end


local function randomFloat(min, max)
    return love.math.random()*(max-min) + min
end


function Leader:growVine()
    
    
    local angle = self.growthAngle
    
    local r = love.math.random(Leader.minBind, Leader.maxBind)
    local dx = math.cos(angle) * r
    local dy = math.sin(angle) * r


    local leader = Leader:new(self.world, dx, dy, angle + randomFloat(-0.3, 0.3), self)
    

    
    if love.math.random() < self.jointChance then
         --self.timer.growth = cron.after(self.growthRate, self.growLeader, self)
        local leader2 = Leader:new(self.world, dx, dy, angle + love.math.random(-1,1) + randomFloat(-0.3, 0.3), self)
        self:transformToJoint(leader, leader2)
    else
        self:transformToVine(leader)
    end


    

    
end


function Leader:shootPattern()
    local pattern = love.math.random(1,#Leader.patterns)
    local delay, vx, vy, bulletTimer
    for i = 1, #Leader.patterns[pattern] do
        local v = Leader.patterns[pattern][i]
        bulletTimer = {}
        bulletTimer.timer = cron.after(math.max(v.delay, 0.001), self.shootBullet, self, v.angle)
        bulletTimer.active = true
        table.insert(self.timer, bulletTimer)
    end
   
end

function Leader:shootBullet(angle)
    local vx, vy
    vx = math.cos(angle) * self.bulletSpeed
    vy = math.sin(angle) * self.bulletSpeed
    
    local enemyBullet = EnemyBullet:new(self.world, self.x, self.y, vx, vy)
end

function Leader:takeHit(damage)
    local pewpew = Leader.hitSound:clone()
    pewpew:play()
    damage = damage or 0
    self.hp = self.hp - damage
    if self.hp <= 0 then
        
        self:destroy()
    end
    
end

function Leader:transformToVine(leader)
    local vine = Vine:new(self)
    leader.parent = vine
    
    self:destroy()
end

function Leader:transformToJoint(leader, leader2)
    local joint = Joint:new(self)
    leader.parent = joint
    leader2.parent = joint
    
    self:destroy()

end

function Leader:getCenter()
    return self.x + self.w/2, self.y + self.h/2
end

function Leader:getLeftTopFromCenter(x, y)
    return x - self.w/2, y - self.h/2
end

function Leader:alignWithParent()
    self.x, self.y = self:getLeftTopFromCenter(self.parent:getCenter())
    self.x = self.x + self.dx
    self.y = self.y + self.dy
end



function Leader:destroy()
    if self.world:hasItem(self) then self.world:remove(self) end
    numberOfLeaders = numberOfLeaders - 1
end


function Leader:getUpdateOrder()
   return self.class.updateOrder or 10000
end

return Leader












