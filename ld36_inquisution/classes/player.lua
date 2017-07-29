local class = require 'lib.middleclass'
local cron = require 'lib.cron'
local tween = require 'lib.tween'



local width = 30
local height = 30

local Entity = require 'classes.entity'


local Player = class('Player', Entity)
Player.static.updateOrder = 1


local deadDuration  = 3   -- seconds until respawn
local runAccel      = 2300 -- the player acceleration while going left/right
local brakeAccel    = 6000
local jumpVelocity  = 600 -- the initial upwards velocity when jumping
local maxVel        = 500
local climbVelocity = 300

local image = love.graphics.newImage('images/player.png')

local abs = math.abs



---------------------------------------------------------------------------------------------------------------
function Player:initialize(world, x,y)
  Entity.initialize(self, world, x, y, width, height)
  self.health = 1
end



---------------------------------------------------------------------------------------------------------------
function Player:filter(other)
  local kind = other.class.name
  if kind == 'Block' then return 'slide' end
end



---------------------------------------------------------------------------------------------------------------
function Player:changeVelocityByKeys(dt)
  self.isJumpingOrFlying = false

  if self.isDead then return end

  local vx, vy = self.vx, self.vy

  local movingx = false
  local movingy = false

  if love.keyboard.isDown("a") then
    vx = vx - dt * (vx > 0 and brakeAccel or runAccel)
    movingx = true
  end
  if love.keyboard.isDown("d") then
    vx = vx + dt * (vx < 0 and brakeAccel or runAccel)
    movingx = true
  end
  if love.keyboard.isDown("w") then
    vy = vy - dt * (vy > 0 and brakeAccel or runAccel)
    movingy = true
  end
  if love.keyboard.isDown("s") then
    vy = vy + dt * (vy < 0 and brakeAccel or runAccel)
    movingy = true
  end

  if movingx == false then
    local brakex = dt * (vx < 0 and brakeAccel or -brakeAccel)
    if math.abs(brakex) > math.abs(vx) then
      vx = 0
    else
      vx = vx + brakex
    end
  end

  if movingy == false then
    local brakey = dt * (vy < 0 and brakeAccel or -brakeAccel)
    if math.abs(brakey) > math.abs(vy) then
      vy = 0
    else
      vy = vy + brakey
    end
  end


  if math.abs(vx) > maxVel then
      vx = vx < 0 and -maxVel or maxVel
  end
  if math.abs(vy) > maxVel then
      vy = vy < 0 and -maxVel or maxVel
  end

  self.vx, self.vy = vx, vy
end




---------------------------------------------------------------------------------------------------------------
function Player:checkIfOnGround(ny)
   if ny < 0 then self.onGround = true end
end



---------------------------------------------------------------------------------------------------------------
function Player:moveColliding(dt)
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
function Player:update(dt)
  self:changeVelocityByKeys(dt)
  self:moveColliding(dt)
end




---------------------------------------------------------------------------------------------------------------
function Player:draw()
  love.graphics.setColor(200, 100, 100, 100)
  love.graphics.rectangle('line', self.l, self.t, self.w, self.h)
  love.graphics.draw(image, self.l, self.t)

end


---------------------------------------------------------------------------------------------------------------


return Player
