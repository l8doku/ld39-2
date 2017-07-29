



lg = love.graphics
lk = love.keyboard
lm = love.mouse
la = love.audio
game = {}
pause = false

menu = false


function game.load()

	love.graphics.setBackgroundColor(25, 25, 25)
	windowWidth, windowHeight = love.window.getMode()
	
  guys = {}
  whites = {}


for i = 1,2000 do
  createAGuy()
end
  
	player={}
	player.x = 100;
	player.y = 100;
	player.v = 1000;

  player.vx = 0;
  player.vy = 0;
	player.firetimer = 0;

eventtimer = 0
eventcd = 1
end


function createAGuy()
guy = {}
guy.x = love.math.random(8000) - 4000
guy.y = love.math.random(8000) - 4000

guy.v = love.math.random(300) + 200

guy.r = love.math.random(100)+50
guy.g = love.math.random(100)+50
guy.b = love.math.random(100)+50

guy.angle = love.math.random()*2*math.pi

guy.vx = guy.v * math.cos(guy.angle)
guy.vy = guy.v * math.sin(guy.angle)

guys[#guys+1] = guy
end


function createWhite()
guy = {}
guy.x = love.math.random(8000) - 4000
guy.y = love.math.random(8000) - 4000

guy.v = love.math.random(300) + 200

guy.r = 255
guy.g = 255
guy.b = 255

guy.angle = love.math.random()*2*math.pi

guy.vx = guy.v * math.cos(guy.angle)
guy.vy = guy.v * math.sin(guy.angle)

whites[#whites+1] = guy
end



function game.update(dt)


eventtimer = eventtimer - dt
if eventtimer < 0 then
  createWhite()
  eventtimer = eventcd
end





  vx = player.vx;
  vy = player.vy;

	if lk.isDown('a') then
		vx = - player.v 
	elseif lk.isDown('d') then
		vx =  player.v
	else
        vx = 0
  end

	
	if lk.isDown('w') then
		vy = - player.v
	elseif lk.isDown('s') then
		vy = player.v
	else
        vy = 0
  end
  
    
    
    player.x = player.x + vx*dt;
    player.y = player.y + vy*dt;
    
    if  player.x <= -3000 then
      player.x = -3000

    end

    if  player.x >= 3000 then
      player.x = 3000

    end


    if player.y <= -3000 then
      player.y = -3000

    end


    if player.y >= 3000 then
      player.y = 3000

    end

 
    player.vx = vx
    player.vy = vy





for i,v in ipairs(guys) do
  v.x = v.x + v.vx*dt
  v.y = v.y + v.vy*dt
  if v.x < -4000 or v.x > 4000 then
      v.vx = - v.vx
  end
  if v.y < -4000 or v.y > 4000 then
      v.vy = - v.vy
  end
  
end


for i,v in ipairs(whites) do
  v.x = v.x + v.vx*dt
  v.y = v.y + v.vy*dt
 
end





    cx = -player.x + 400;
    cy = -player.y + 300









end

function game.keypressed(key, unicode)


end



function game.draw()



lg.translate(cx,cy)

lg.setColor(30,30,30)
for i = -4000,4000, 40 do 
  for j =  -4000,4000, 40 do 
    lg.rectangle("fill",i,j,35,35 )
  end
end




for i,v in ipairs(guys) do
  lg.setColor(v.r,v.g,v.b,100)
  lg.rectangle("fill", v.x,v.y,10,10)
  lg.setColor(v.r,v.g,v.b)
  lg.rectangle("line", v.x,v.y,10,10)
end


for i,v in ipairs(whites) do
  lg.setColor(v.r,v.g,v.b)
  lg.rectangle("fill", v.x,v.y,10,10)
end



lg.setColor(255,255,255)
lg.rectangle("fill", player.x,player.y,10,10)

end