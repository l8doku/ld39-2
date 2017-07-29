--[[
-- Map class
-- The map is in charge of creaating the scenario where the game is played - it spawns a bunch of rocks, walls, floors and guardians, and a player.
-- Map:reset() restarts the map. It can be done when the player dies, or manually.
-- Map:update() updates the visible entities on a given rectangle (by default, what's visible on the screen). See main.lua to see how to update
-- all entities instead.
--]]
local class       = require 'lib.middleclass'
local bump        = require 'lib.bump'

local Grid        = require 'lib.jumper.grid'
local Player      = require 'classes.player'
local Enemy       = require 'classes.enemy'
local Block       = require 'classes.block'
local Sti         = require 'lib.sti'

local random = math.random


local sortByUpdateOrder = function(a,b)
  return a:getUpdateOrder() < b:getUpdateOrder()
end

local sortByCreatedAt = function(a,b)
  return a.created_at < b.created_at
end

local Map = class('Map')

function Map:initialize(width, height, camera)
  self.width  = width
  self.height = height
  self.camera = camera
  self.map = Sti.new('maps/map1.lua')
  self.paths = {}
  self.enemies = {}
  self:reset()
end

function Map:reset()

  local width, height = self.width, self.height
  self.paths = {}
  self.enemies = {}

  self.world  = {} --TODO world
  self.player = Player:new(self.world, 200, 200)


----------------------------------------------------------------LOADING
  for i,v in ipairs(self.map.layers["solid"].objects) do
      Block:new(self.world, v.x, v.y, v.width, v.height)
  end

  -- Load markers
  for num = 0, 9 do
    if self.map.layers['markers'..num] then
      local path = {}
      for i,v in ipairs(self.map.layers['markers'..num].objects) do
          local m = Marker:new(self.world, v.x, v.y, v.width, v.height)
          path[tonumber(v.name)] = m
      end
      table.insert(self.paths, path)
    end
  end

  local gridMap = {}
  for y = 1, self.map.layers['solidtiles'].height do
    gridMap[y] = {}
    for x = 1, self.map.layers['solidtiles'].width do
      gridMap[y][x] = self.map.layers['solidtiles'].data[y][x].id
    end
  end

  self.grid = Grid(gridMap)
  local enemy = Enemy:new(self, 300, 300)
  table.insert(self.enemies, enemy)
end


function Map:update(dt, l,t,w,h)
  l,t,w,h = l or 0, t or 0, w or self.width, h or self.height
  local visibleThings, len = self.world:queryRect(l,t,w,h)

  table.sort(visibleThings, sortByUpdateOrder)

  for i=1, len do
    visibleThings[i]:update(dt)
  end
end

function Map:draw(l,t,w,h)
  self.map:draw()

  local visibleThings, len = self.world:queryRect(l,t,w,h)

  table.sort(visibleThings, sortByCreatedAt)

  for i=1, len do
    visibleThings[i]:draw(drawDebug)
  end
end

function Map:countItems()
  return self.world:countItems()
end


return Map
