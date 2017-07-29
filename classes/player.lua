local class = require 'lib.middleclass'
local cron = require 'lib.cron'
local tween = require 'lib.tween'
local util = require "util"

local Entity = require 'classes.entity'
local Player = class('Player', Entity)
-- local Player = class("Player"):include(Stateful)

Player.static.updateOrder = 1
Player.static.shootSounds = {}
Player.static.shootSounds [1] = love.audio.newSource('sounds/shoot_quiet.wav','static')
Player.static.shootSounds [1]:setVolume(0.5)
Player.static.hitSound = love.audio.newSource('sounds/player_hit.wav','static')




local deadDuration  = 3   -- seconds until respawn
local runAccel      = 2300 -- the player acceleration while going left/right
local brakeAccel    = 6000
local jumpVelocity  = 600 -- the initial upwards velocity when jumping
local maxVel        = 500
local climbVelocity = 300
local width         = 32
local height        = 64


local abs = math.abs

function Player:initialize(world, x, y)

  Entity.initialize(self, world, x, y, width, height)
  self.health = 1

    self.maxSpeed = 500

    self.image = lg.newImage("images/player.png")
    self.imageInv = lg.newImage('images/player_inv.png')

  --   self.bulletSpeedY = -800
  --   self.guiFont = lg.newFont(20)
	-- self.guiFont = lg.newFont("fonts/dspixcyr.ttf", 30 )
  --   lg.setFont(self.guiFont)

    -- self.fireRate = 0.1
    -- self.hp = 3
    -- self.score = 0
    -- self.invincibilityTime = 2

    self.timer = {}
    -- self.timer.shoot = cron.every(self.fireRate, self.shoot, self)
    --
    -- self.laserReady = true
    -- self.laserTimer = 3
    -- self.laserTimerMax = 3
    -- self.laserCost = 1
    --
    -- self.shieldReady = true
    -- self.shieldTimer = 25
    -- self.shieldTimerMax = 25
    -- self.shieldCost = self.shieldTimerMax
    --
    --
    -- self.world:add(self, self.x, self.y, self.hitBoxWidth, self.hitBoxHeight)


    -- local imagewidth, imageheight = self.image:getDimensions()
    -- assert(self.visualWidth == imagewidth, "image file width is "..imagewidth..", image object width is "..self.visualWidth)
    -- assert(self.visualHeight == imageheight, "image file height is "..imageheight..", image object height is "..self.visualHeight)
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
  -- self:updateTimers(dt) TODO implement this in Entity
  self:changeVelocityByKeys(dt)
  self:moveColliding(dt)
end
-- function Player:update(dt)
--     -- if self.laserTimer < self.laserTimerMax then
--     --     self.laserTimer = self.laserTimer + dt
--     -- end
--     --
--     -- if self.shieldTimer < self.shieldTimerMax then
--     --     self.shieldTimer = self.shieldTimer + dt
--     -- end
--
--     for i,v in pairs(self.timer) do
--         v:update(dt)
--     end
--
--     local mx, my = lm.getPosition()
--
--     local dx = mx - self.x + self.hitBoxWidth/2 - self.visualWidth/2
--     local dy = my - self.y + self.hitBoxHeight/2 - self.visualHeight/2
--
--     local r = math.sqrt(dx*dx + dy*dy)
--     local stepLimit = self.maxSpeed*dt
--     local goalX, goalY
--     if r > stepLimit then
--         dx = dx * stepLimit/r
--         dy = dy * stepLimit/r
--     end
--     goalX = self.x + dx
--     goalY = self.y + dy
--     local actualX, actualY, cols, len = self.world:move(self, goalX, goalY, self.filter)
--
--     self.x = actualX
--     self.y = actualY
--
-- end

function Player:mousepressed(x, y, button)
    if button == 1 then
      local ouch = Player.hitSound:clone()
      ouch:play()
    -- elseif button == 2 then
    --     if self.shieldTimer >= self.shieldCost then
    --         self.shieldTimer = self.shieldTimer  - self.shieldCost
    --         local shield1 = Shield:new(self.world, self, 'horizontal')
    --         local shield2 = Shield:new(self.world, self, 'vertical')
    --     end
    end
end

function Player:mousereleased()

end

function Player:draw(drawDebug)

    lg.setColor(255,255,255);
    local centerX, centerY = self:getCenter()


    lg.draw(self.image, centerX, centerY, 0, 1, 1, self.w/2, self.h/2)
    if drawDebug then
      util.drawFilledRectangle(self.l,self.t,self.w,self.h)
    end


    -- lg.setColor(255,255,255);
    -- lg.print('HP = '..self.hp,0,0)
    --
    -- lg.setColor(255,255,255);
    -- lg.rectangle('fill', love.graphics.getWidth()-10,
    --                     (1-self.laserTimer/self.laserTimerMax)*love.graphics.getHeight(),
    --                     10,
    --                     self.laserTimer/self.laserTimerMax*love.graphics.getHeight())
    --
    -- lg.setColor(0,0,0);
    -- lg.rectangle('fill', love.graphics.getWidth()-10,
    --                     (1-self.laserCost/self.laserTimerMax)*love.graphics.getHeight(),
    --                     10,
    --                     3)
    --
    -- lg.setColor(150,150,170);
    -- lg.rectangle('fill', love.graphics.getWidth()-20,
    --                     (1-self.shieldTimer/self.shieldTimerMax)*love.graphics.getHeight(),
    --                     10,
    --                     self.shieldTimer/self.shieldTimerMax*love.graphics.getHeight())
    --
    -- lg.setColor(0,0,0);
    -- lg.rectangle('fill', love.graphics.getWidth()-20,
    --                     (1-self.shieldCost/self.shieldTimerMax)*love.graphics.getHeight(),
    --                     10,
    --                     3)



end


function Player:shoot()
    local pewpew = Player.shootSounds[love.math.random(1,#Player.shootSounds)]:clone()
    pewpew:play()
    local cx, cy = self:getCenter()
    local bullet = Bullet:new(self.world, cx, cy, 0, self.bulletSpeedY)
end

function Player:getUpdateOrder()
   return self.class.updateOrder or self.updateOrder or 10000
end

-- function Player:getCenter()
--     return self.x + self.hitBoxWidth/2, self.y + self.hitBoxHeight/2
-- end


function Player:filter(other)
  local kind = other.class.name
  if kind == 'Block' then return 'slide' end
end

function Player:takeHit()
    if not self.invincible then
        local ouch = Player.hitSound:clone()
        ouch:play()
        self.hp = self.hp - 1

        if self.hp <= 0 then
            pause = true
            youlose = true
        else
            self.invincible = true
            self.timer.hitFlash = cron.after(self.invincibilityTime, function() self.invincible = false end)
        end
    end
end

return Player
