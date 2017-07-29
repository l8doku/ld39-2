local class = require 'lib.middleclass'
local cron = require 'lib.cron'
local tween = require 'lib.tween'


local Grid = require 'lib.jumper.grid'
local Pathfinder = require 'lib.jumper.pathfinder'

local Marker = require 'classes.marker'
local Entity = require 'classes.entity'
local Enemy = class('Enemy', Entity)


Enemy.static.updateOrder = 1


local deadDuration  = 3   -- seconds until respawn
local runAccel      = 1300 -- the player acceleration while going left/right
local brakeAccel    = 9000
local patrolVel     = 100
local chaseVel      = 300

local image = love.graphics.newImage('images/player.png')

local abs = math.abs


local width = 15
local height = 40


---------------------------------------------------------------------------------------------------------------
function Enemy:initialize(map, x,y)
  Entity.initialize(self, map.world, x, y, width, height)
  self.l = x
  self.t = y
  self.currentPath = 1
  self.currentMarker = 1
  self.map = map
  self.state = 'patrol'
  self.speed = patrolVel
  
  self.sightDirection = 0
  self.sightRange = 500
  self.sightFov = 80/180*math.pi
  self.activeTweens = {}
  self.idleTimer = cron.after(4, self.goToNextMarker, self)
  
  self.currentNode = 0
  self.walkable = 1
  
  self.needsPath = true
  self.path = {}

  self.myFinder = Pathfinder(self.map.grid, 'JPS', self.walkable) 
  
end



---------------------------------------------------------------------------------------------------------------
function Enemy:filter(other)
  local kind = other.class.name
  if kind == 'Block' then return 'slide' end
end

function Enemy:filterForQuery(other)
  local kind = self.class.name
  if kind == 'Block' then return 'slide' end
  if kind == 'Player' then return 'slide' end
  
end


function Enemy:goToNextNode()
  
end


---------------------------------------------------------------------------------------------------------------
function Enemy:goToNextMarker()
  self.state = 'patrol'
  self.currentMarker = math.fmod(self.currentMarker, #self.map.paths[self.currentPath]) + 1
end



local len2 = 0
---------------------------------------------------------------------------------------------------------------
function Enemy:checkLineForPlayer()
  local sx, sy = self:getCenter()
  local px, py = self.map.player:getCenter()
  local items, len = self.map.world:querySegment(sx,sy,px,py,self.filterForQuery)
  len2 = len
  for i = 1, len do
    if items[1].class.name == 'Player' then
      return true
    else
      return false
    end
  end
end


---------------------------------------------------------------------------------------------------------------
function Enemy:updateTimers(dt)
  local complete
  if self.state == 'idle' then
    self.idleTimer:update(dt)
  end
  
  for i,v in pairs(self.activeTweens) do
    complete = v:update(dt)
    if complete then
      self.activeTweens[i] = nil
      if i == 'lookLeftTween' then
        self.activeTweens.lookRightTween = tween.new(2, self, {sightDirection = self.sightDirection + 120/180*math.pi},'inOutBack')
      elseif i == 'lookRightTween' then
        local currentMarker = math.fmod(self.currentMarker, #self.map.paths[self.currentPath]) + 1
        local marker = self.map.paths[self.currentPath][currentMarker]
        local targetX, targetY = marker:getCenter()
        local dx, dy = targetX - self.l, targetY - self.t
        local directionAngle = math.atan2(dy, dx)
        if self.sightDirection - directionAngle > math.pi then
          directionAngle = directionAngle + 2*math.pi
        elseif directionAngle - self.sightDirection > math.pi then
          directionAngle = directionAngle - 2*math.pi
        end
        self.activeTweens.lookNextTween = tween.new(1, self, {sightDirection = directionAngle},'inOutBack')
      end
    end
  end
end



function Enemy:checkAreaForPlayer()
  local distance, angle
  local px, py = self.map.player:getCenter()
  local dx, dy = px - self.l, py - self.t
  distance = math.sqrt(dx*dx + dy*dy)
  angle = math.atan2(dy, dx)
  if distance < self.sightRange and math.abs(angle - self.sightDirection) < self.sightFov/2 then
    if self:checkLineForPlayer() then
      self.state = 'chase'
    elseif self.state == 'chase' then
      self.state = 'patrol'
    end
  end
  
end



--------------------------------------------------------------------------------------------------------------------
function Enemy:selectTarget()
  local targetX, targetY
  local vel
  if self.state == 'patrol' then
    local marker = self.map.paths[self.currentPath][self.currentMarker]
    targetX, targetY = marker:getCenter()
    vel = patrolVel
  elseif self.state == 'chase' then
    targetX, targetY = self.map.player:getCenter()
    vel = chaseVel
    self.needsPath = true
  else
    targetX, targetY = self:getCenter()
    vel = 0
  end
  self.speed = vel
  return targetX, targetY
end



function Enemy:updatePath(targetx, targety)
  self.path = {}
  local sx, sy = self:getCenter()
  local startx, starty = self.map.map:convertScreenToWorld(sx, sy)
  startx, starty = math.floor(startx), math.floor(starty)
  local endx, endy = self.map.map:convertScreenToWorld(targetx, targety)
  endx, endy = math.floor(endx), math.floor(endy)
  local path = self.myFinder:getPath(startx, starty, endx, endy)
  for node, num in path:nodes() do
    self.path[num] = node
  end
end


--------------------------------------------------------------------------------------------------------------------
function Enemy:changeVelocityByAi(dt)
  

--  local path = self.myFinder:getPath(startx, starty, endx, endy)
--  if path then
--    print(('Path found! Length: %.2f'):format(path:getLength()))
--      for node, count in path:nodes() do
--        print(('Step: %d - x: %d - y: %d'):format(count, node:getX(), node:getY()))
--      end
--  end  
  
  local targetx, targety = self:selectTarget()
  if self.needsPath then
    self:updatePath(targetx, targety)
    self.currentNode = 1
  end
  
  if self.state ~= 'idle' then
    
    -- if there is no current path, then calculate one and follow it
    -- if chasing the player, recalculate path every step, otherwise just follow the current one

  
    local px, py = self.path[self.currentNode]:getX(), self.path[self.currentNode]:getY() 
    local waypointx, waypointy = self.map.map:convertWorldToScreen(px, py)
    local dx, dy = waypointx - self.l, waypointy - self.t
    local directionAngle = math.atan2(dy, dx)
    if(math.sqrt(dx*dx + dy*dy) > 10) then
      self.sightDirection = directionAngle
      self.vx, self.vy = self.speed*math.cos(directionAngle), self.speed*math.sin(directionAngle)
    elseif self.currentNode == #self.path then
      self.vx, self.vy = 0, 0
      self.state = 'idle'
      self.idleTimer:reset()
      self.activeTweens.lookLeftTween = tween.new(1, self, {sightDirection = directionAngle - 60/180*math.pi},'inOutBack')
    else
      self.currentNode = self.currentNode + 1
      px, py = self.path[self.currentNode]:getX(), self.path[self.currentNode]:getY() 
      waypointx, waypointy = self.map.map:convertWorldToScreen(px, py)
      dx, dy = waypointx - self.l, waypointy - self.t
      directionAngle = math.atan2(dy, dx)
      self.sightDirection = directionAngle
      self.vx, self.vy = self.speed*math.cos(directionAngle), self.speed*math.sin(directionAngle)
    end
  end
  
end



---------------------------------------------------------------------------------------------------------------
function Enemy:moveColliding(dt)
  self.onGround = false
  self.canClimb = false
  local world = self.world

  local future_l = self.l + self.vx * dt
  local future_t = self.t + self.vy * dt

  local next_l, next_t, cols, len = world:move(self, future_l, future_t, self.filter)

  for i=1, len do
    local col = cols[i]
    self:changeVelocityByCollisionNormal(col.normal.x, col.normal.y)
  end

  self.l, self.t = next_l, next_t
end





---------------------------------------------------------------------------------------------------------------
function Enemy:update(dt)
  self:updateTimers(dt)
  self:checkAreaForPlayer()
  self:changeVelocityByAi(dt)
  

  self:moveColliding(dt)
end




---------------------------------------------------------------------------------------------------------------
function Enemy:draw()
  -- debug rect
  love.graphics.setColor(100, 100, 170, 150)
  love.graphics.rectangle('line', self.l, self.t, self.w, self.h)
  
  --sprite
  love.graphics.draw(image, self.l, self.t)

--debug text
  local text = ''..self.state..'\n'..self.currentMarker..'\n'..self.sightDirection..'\n'..len2
  love.graphics.print(text, self.l, self.t + self.h)
  
  --fov
  local cx, cy = self:getCenter()
  local angle1 = self.sightDirection - self.sightFov/2
  local angle2 = self.sightDirection + self.sightFov/2
  local segments = 20
  love.graphics.setColor(255, 127, 127, 100)
  love.graphics.arc('fill', cx, cy, self.sightRange, angle1, angle2, segments)
end


---------------------------------------------------------------------------------------------------------------


return Enemy

