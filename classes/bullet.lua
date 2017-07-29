
local class = require 'lib.middleclass'
local Stateful = require 'lib.stateful'
local Bullet = class("Bullet"):include(Stateful)
local cron = require 'lib.cron'


Bullet.static.updateOrder = 15
Bullet.static.image = lg.newImage('images/player_bullet.png')
function Bullet:initialize(world, x, y, vx, vy)

    self.world = world
    self.x = x
    self.y = y
    self.w = 5
    self.h = 5
    self.vx = vx
    self.vy = vy or 0
    self.isDead = false
    self.damage = 50

    self.timer = {}
    self.timeToLive = 10
    self.timer.timeToLive = cron.after(self.timeToLive, self.destroy, self)

    self.world:add(self, self.x, self.y, self.w, self.h)
end


function Bullet:update(dt)



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

function Bullet:mousepressed()

end

function Bullet:mousereleased()

end

function Bullet:draw()
    lg.setColor(255, 255, 255)
    lg.draw(Bullet.image,self.x,self.y)
end


function Bullet:destroy()
    self.world:remove(self)
end


function Bullet:filter(other)
  local kind = other.class.name
  if kind == 'Vine' or kind == 'Leader' or kind == 'Joint' or kind == 'Root' then return 'slide' end
end

function Bullet:getUpdateOrder()
   return self.class.updateOrder or self.updateOrder or 10000
end

return Bullet
