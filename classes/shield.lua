local class = require 'lib.middleclass'
local cron = require 'lib.cron'
local tween = require 'lib.tween'

local Shield = class("Shield")

Shield.static.updateOrder = 20000
Shield.static.image = lg.newImage('images/shield.png')
function Shield:initialize(world, player, shieldType)

    self.player = player
    self.world = world
    
    self.shieldType = shieldType
   
   
    self.image = lg.newImage("images/shield.png")
    
    self.radius = 30
    self.cx, self.cy = player:getCenter()
    if shieldType == 'horizontal' then
        
        self.x = self.cx - self.radius
        self.y = self.cy - self.radius/2
        self.w = self.radius * 2
        self.h = self.radius
    
    elseif shieldType == 'vertical' then
        self.x = self.cx - self.radius/2
        self.y = self.cy - self.radius
        self.w = self.radius
        self.h = self.radius * 2
    else
        error('Shield type should be horizontal or vertical')
    end

    self.lifeTime = 5
    self.timer = {}
    self.timer.live = cron.after(self.lifeTime, self.destroy, self)
    
  
    self.world:add(self, self.x, self.y, self.w, self.h)

end


function Shield:update(dt)
    
    
    local goalX, goalY
    
    self.cx, self.cy = self.player:getCenter()
    if self.shieldType == 'horizontal' then
        
        
        goalX = self.cx - self.radius
        goalY = self.cy - self.radius/2
    
    elseif self.shieldType == 'vertical' then
        goalX = self.cx - self.radius/2
        goalY = self.cy - self.radius
    end
        
    local actualX, actualY, cols, len = self.world:move(self, goalX, goalY, self.filter)
        
    for i=1,len do
        cols[i].other:destroy()
    end
        
    self.x = actualX
    self.y = actualY
    
    for i,v in pairs(self.timer) do
        v:update(dt)
    end
    

    


end
 
function Shield:mousepressed(x, y, button)
  
end

function Shield:mousereleased()
    
end

function Shield:draw()
    
    if self.shieldType == 'horizontal' then
        lg.setColor(255,255,255);
        local centerX, centerY = self:getCenter()
        
        lg.draw(Shield.image, centerX, centerY, 0, 1, 1, self.radius, self.radius)
    end
    
end

function Shield:destroy()
    if self.world:hasItem(self) then self.world:remove(self) end
end


function Shield:getUpdateOrder()
   return self.class.updateOrder or self.updateOrder or 10000
end

function Shield:getCenter()
    return self.x + self.w/2, self.y + self.h/2
end

function Shield:filter(other)
    local kind = other.class.name
    if kind == 'EnemyBullet' then return 'cross' end
end

function Shield:takeHit()
end


return Shield
