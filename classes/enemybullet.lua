
local class = require 'lib.middleclass'
local Stateful = require 'lib.stateful'
local EnemyBullet = class("EnemyBullet"):include(Stateful)
local cron = require 'lib.cron'


EnemyBullet.static.updateOrder = 16
EnemyBullet.static.image = lg.newImage('images/enemy_bullet.png')
function EnemyBullet:initialize(world, x, y, vx, vy)

    self.world = world
    self.x = x
    self.y = y
    self.w = 5
    self.h = 5
    self.vx = vx
    self.vy = vy or 0
    self.damage = 1
    
    self.timer = {}
    self.timeToLive = 10
    self.timer.timeToLive = cron.after(self.timeToLive, self.destroy, self)
    
    self.world:add(self, self.x, self.y, self.w, self.h)
end


function EnemyBullet:update(dt)
    

    
    local goalX, goalY
    goalX = self.x + self.vx*dt
    goalY = self.y + self.vy*dt
    
    local actualX, actualY, cols, len = self.world:move(self, goalX, goalY, self.filter)
    self.x = actualX
    self.y = actualY
    for i=1,len do
        cols[i].other:takeHit(self.damage)
    end
    if len > 0 then
        self:destroy()
    end
end

function EnemyBullet:mousepressed()
    
end

function EnemyBullet:mousereleased()
    
end

function EnemyBullet:draw()
    
    lg.setColor(255,255,255)
    local centerX, centerY = self:getCenter()
    lg.draw(EnemyBullet.image, centerX, centerY, 0, 1, 1, EnemyBullet.image:getWidth()/2, EnemyBullet.image:getHeight()/2)
    
--    lg.setColor(50, 100, 0)
--    lg.rectangle("fill", self.x, self.y, self.w, self.h)
end


function EnemyBullet:destroy()
    if self.world:hasItem(self) then self.world:remove(self) end
end

function EnemyBullet:getCenter()
    return self.x + self.w/2, self.y + self.h/2
end

function EnemyBullet:filter(other)
  local kind = other.class.name
  if kind == 'Player' then return 'slide' end
  if kind == 'Shield' then return 'bounce' end
end

function EnemyBullet:getUpdateOrder()
   return self.class.updateOrder or 10000
end

return EnemyBullet
